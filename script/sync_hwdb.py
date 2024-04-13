import os
# udevadm hwdb is deprecated. Use systemd-hwdb instead.
# os.system('sudo udevadm hwdb --update')
os.system('sudo systemd-hwdb update')
os.system('sudo udevadm trigger')
