import os
os.system('sudo udevadm hwdb --update')
os.system('sudo udevadm trigger')
