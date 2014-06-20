#!/bin/bash

feh --bg-scale /usr/share/backgrounds/gnome/`python -c 'import os,random; print random.choice(os.listdir("/usr/share/backgrounds/gnome"))'`
