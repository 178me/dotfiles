import sys
import os
import re
import requests

host = "http://dl.corp.linakesi.cn"
url = "https://dl.lazycat.cloud/client/android/apk/"


def get_latest_apk_url():
    text = requests.get(url).text
    print(text)
    # 定义正则表达式模式
    pattern = r"v\d+\.\d+\.\d+.\d+"

    # 在文本中查找匹配的版本号
    versions = re.findall(pattern, text)
    versions = tuple(map(lambda s: s.replace("-", "."), versions))

    # 将版本号转换为数字并找到最大值
    max_version = max(
        map(lambda s: tuple(map(int, s[1:].split('.'))), versions))

    # 将最大版本号转换回字符串格式
    latest_version = 'v' + '.'.join(map(str, max_version))

    # 在原始文本中查找最新版本的apk文件名
    latest_apk = re.search(
        f"lzc-client-android-{latest_version}-[a-z0-9]+\\.apk", text).group()
    return url + latest_apk


def get_testing_apk_url():
    return f"{host}/client/android/lzc-client-android.testing.apk"


def get_stable_apk_url():
    return f"{host}/client/android/lzc-client-android.apk"


filename = "lzc-client-android-dev.apk"

apk_url = ""

if len(sys.argv) >= 2:
    if sys.argv[1] == "test":
        apk_url = get_testing_apk_url()
    elif sys.argv[1] == "stable":
        apk_url = get_stable_apk_url()
    elif sys.argv[1] == "custom":
        apk_url = "http://dl.corp.linakesi.cn/client/android/apk/lzc-client-android-1.0.80.apk"
else:
    apk_url = get_latest_apk_url()

os.system(f"adb wait-for-device")
os.system(f"wget {apk_url} -O {filename}")
#
os.system(f"adb install {filename}")
os.system(f"rm {filename}")
