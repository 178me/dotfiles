"修改窗口布局"
import sys
import os
#  print(sys.argv[1])

home = "/home/yzl178me/.config/i3/"
#  print('sed -i "s/echo [n|m][r|l|c]/echo '+sys. argv[1]+'/g" '+home+'config')
#  exit(0)

os.system('sed -i "s/echo [n|m][r|l|c]/echo ' +
          sys. argv[1]+'/g" '+home+'config')
os.system("notify-send -t 3000 '切换布局方式'"+sys.argv[1])
os.system("i3-msg reload")
#  print(toggle)
