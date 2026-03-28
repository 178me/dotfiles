import sys
import os
import re
import requests

host = "https://dl.corp.linakesi.cn"
url = "https://dl.corp.linakesi.cn/client/android/apk/"


def parse_version(version):
    return tuple(map(int, version.split('.')))


def get_latest_apk_url():
    text = requests.get(url, verify=False).text
    # print(text)
    # 定义正则表达式模式
    pattern = r'(\d+\.\d+\.\d+)'

    # 在文本中查找匹配的版本号
    versions = re.findall(pattern, text)
    versions = set(map(lambda s: s.replace("-", "."), versions))

    print(versions)
    # 将版本号转换为数字并找到最大值
    max_version = max(versions, key=parse_version)
    # max_version = max(
    #     map(lambda s: tuple(map(int, s[1:].split('.'))), versions))

    # 在原始文本中查找最新版本的apk文件名
    print(max_version)
    latest_apk = f"lzc-client-android-{max_version}.apk"
    print(latest_apk)
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
        apk_url = "https://dl.corp.linakesi.cn/client/android/lzc-client-android.testing.apk"
else:
    apk_url = get_testing_apk_url()
    # apk_url = get_latest_apk_url()

os.system(f"adb wait-for-device")
os.system(f"wget --no-check-certificate {apk_url} -O {filename}")
#
os.system(f"adb install {filename}")
os.system(f"rm {filename}")
