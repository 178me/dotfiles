''' 鼠标跟随聚焦开关 '''
import os

home = "/home/yzl178me/.config/i3/"
toggle = ""
with open(home+"config") as lines:
    for line in lines:
        toggle = line
        break

print(toggle)
if toggle.rfind("no") != -1:
    os.system('sed -i "1 s|no|yes| " '+home+'config')
    os.system("notify-send -t 3000 '聚焦跟随鼠标'")
else:
    os.system('sed -i "1 s|yes|no| " '+home+'config')
    os.system("notify-send -t 3000 '聚焦不跟随鼠标'")

os.system("i3-msg reload")
#  print(toggle)
