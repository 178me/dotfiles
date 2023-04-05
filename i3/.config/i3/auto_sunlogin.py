''' i3 重新加载之后交换键位 '''
import os
import time

os.system("notify-send -t 3000 '调整远程控制窗口'")
os.system("i3-msg scratchpad show")
time.sleep(0.1)
os.system("i3-msg scratchpad show")
#  os.system("i3-msg fullscreen toggle")
#  os.system("i3-msg floating enable")
