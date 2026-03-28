#!/usr/bin/env python3

import time
import os
time.sleep(3)
os.system('sudo systemd-hwdb update')
os.system('sudo udevadm trigger')
