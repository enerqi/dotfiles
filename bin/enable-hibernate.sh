#!/bin/bash
# Enable hibernation on Ubuntu 26.04 with LUKS + LVM root and a swapfile.
#
# Why this is needed: hibernate writes a full memory image to swap, so swap
# must be >= RAM. This box has 14Gi RAM and a 4G /swap.img, so
# `loginctl can-hibernate` returns "no" and hibernate silently degrades to a
# shutdown (losing the session).
#
# Safe to re-run. Run with sudo. Requires a reboot afterwards.
set -euo pipefail

SWAPSIZE_GB=20                     # >= RAM (14Gi), with headroom for real swap use
SWAPFILE=/swap.img

[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }

echo "== preflight =="
lockdown=$(cat /sys/kernel/security/lockdown 2>/dev/null || echo "[none]")
case "$lockdown" in
  *"[none]"*) : ;;
  *) echo "FAIL: kernel lockdown active ($lockdown); hibernate is blocked. Disable Secure Boot." >&2; exit 1 ;;
esac
grep -qw disk /sys/power/state || { echo "FAIL: kernel has no hibernate support" >&2; exit 1; }

ROOT_SRC=$(findmnt -no SOURCE /)
ROOT_UUID=$(findmnt -no UUID /)
ROOT_FSTYPE=$(findmnt -no FSTYPE /)
[[ "$ROOT_FSTYPE" == "ext4" ]] || { echo "FAIL: root is $ROOT_FSTYPE; resume_offset logic here assumes ext4" >&2; exit 1; }
[[ -n "$ROOT_UUID" ]] || { echo "FAIL: could not read root UUID" >&2; exit 1; }

RAM_KB=$(awk '/MemTotal/{print $2}' /proc/meminfo)
NEED_GB=$(( (RAM_KB / 1024 / 1024) + 1 ))
(( SWAPSIZE_GB >= NEED_GB )) || { echo "FAIL: SWAPSIZE_GB=$SWAPSIZE_GB < RAM ${NEED_GB}G" >&2; exit 1; }

AVAIL_GB=$(df --output=avail -BG / | tail -1 | tr -dc '0-9')
(( AVAIL_GB > SWAPSIZE_GB + 10 )) || { echo "FAIL: only ${AVAIL_GB}G free on /" >&2; exit 1; }

echo "root=$ROOT_SRC uuid=$ROOT_UUID ram=${NEED_GB}G swap->${SWAPSIZE_GB}G free=${AVAIL_GB}G"

echo "== resize swapfile =="
swapoff "$SWAPFILE" 2>/dev/null || true
rm -f "$SWAPFILE"
# dd, not fallocate: guarantees fully allocated blocks with no unwritten
# extents, which the resume path requires.
dd if=/dev/zero of="$SWAPFILE" bs=1M count=$((SWAPSIZE_GB * 1024)) status=progress
chmod 600 "$SWAPFILE"
mkswap "$SWAPFILE"
swapon "$SWAPFILE"

echo "== compute resume_offset =="
if filefrag -v "$SWAPFILE" | grep -q unwritten; then
  echo "FAIL: swapfile has unwritten extents; resume cannot use it" >&2; exit 1
fi
OFFSET=$(filefrag -v "$SWAPFILE" | awk '$1=="0:"{gsub(/\./,"",$4); print $4; exit}')
[[ "$OFFSET" =~ ^[0-9]+$ ]] || { echo "FAIL: could not parse resume_offset (got '$OFFSET')" >&2; exit 1; }
echo "resume_offset=$OFFSET"

echo "== initramfs resume conf =="
mkdir -p /etc/initramfs-tools/conf.d
printf 'RESUME=UUID=%s\n' "$ROOT_UUID" > /etc/initramfs-tools/conf.d/resume

echo "== grub cmdline =="
cp -a /etc/default/grub "/etc/default/grub.bak.$(date +%Y%m%d%H%M%S)"
CUR=$(grep -oP '(?<=^GRUB_CMDLINE_LINUX_DEFAULT=").*(?="$)' /etc/default/grub)
# strip any previous resume settings so this stays idempotent
CLEAN=$(sed -E 's/\bresume(_offset)?=[^ ]*//g; s/  +/ /g; s/^ | $//g' <<<"$CUR")
NEW="$CLEAN resume=UUID=$ROOT_UUID resume_offset=$OFFSET"
NEW=$(sed -E 's/^ +//; s/ +$//' <<<"$NEW")
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$NEW\"|" /etc/default/grub
grep '^GRUB_CMDLINE_LINUX_DEFAULT' /etc/default/grub

echo "== regenerate =="
update-initramfs -u -k all
update-grub

echo "== polkit =="
# Sizing the swap is only half the job. Ubuntu also disables hibernation in
# policy: /usr/share/polkit-1/rules.d/com.ubuntu.desktop.rules contains
# "Disable hibernate by default in Ubuntu" and returns polkit.Result.NO
# unconditionally. That is why `sudo systemctl hibernate` works (root bypasses
# polkit) while a desktop button gets "Call to Hibernate failed: Access denied".
# Rules in /etc/polkit-1/rules.d are evaluated before /usr/share and the first
# result wins, so this overrides it without touching the vendor file (which a
# package update would overwrite). polkitd reloads automatically.
#
# hibernate-ignore-inhibit is deliberately omitted, so applications that
# inhibit sleep are still respected.
install -d -m 700 -o root -g root /etc/polkit-1/rules.d
cat > /etc/polkit-1/rules.d/10-enable-hibernate.rules <<'RULES'
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.hibernate" ||
         action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
         action.id == "org.freedesktop.login1.handle-hibernate-key" ||
         action.id == "org.freedesktop.upower.hibernate") &&
        subject.active == true && subject.local == true &&
        subject.isInGroup("sudo")) {
            return polkit.Result.YES;
    }
});
RULES
chmod 644 /etc/polkit-1/rules.d/10-enable-hibernate.rules

echo
echo "DONE. Reboot, then check that this prints yes:"
echo "  busctl --system call org.freedesktop.login1 /org/freedesktop/login1 \\"
echo "         org.freedesktop.login1.Manager CanHibernate"
echo "(note: 'na' means unsupported, 'no' means permission denied)"
echo "Then test with: systemctl hibernate"
