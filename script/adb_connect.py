import os
import sys
from time import sleep
# 设置默认的设备IP地址和端口号
DEFAULT_DEVICE_IP = 'Redmi-K50.lan'
DEFAULT_DEVICE_PORT = '5555'

# 如果有传递命令行参数，使用命令行参数，否则使用默认值
if len(sys.argv) >= 2:
    os.system(f'adb connect {DEFAULT_DEVICE_IP}:{sys.argv[1]}')
    os.system(f'adb tcpip {DEFAULT_DEVICE_PORT}')
    os.system(f'adb disconnect')
sleep(0.3)
os.system(f'adb connect {DEFAULT_DEVICE_IP}:{DEFAULT_DEVICE_PORT}')
