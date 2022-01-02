#!/bin/bash

feh --bg-scale /usr/share/backgrounds/`python2 -c 'import os,random; print random.choice( [f for f in os.listdir("/usr/share/backgrounds") if f.endswith("jpg") or f.endswith("png")] )'`
