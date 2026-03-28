import datetime
import pyperclip

# 获取当前时间
current_time = datetime.datetime.now()

# 格式化时间为 yyyymmddhhmmss
formatted_time = current_time.strftime("%Y%m%d%H%M%S")

# 将格式化的时间复制到剪贴板
pyperclip.copy(formatted_time)
