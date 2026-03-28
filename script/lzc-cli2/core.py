import re
import os
import sys
import json
import requests
import pyperclip
import subprocess
from dataclasses import dataclass


@dataclass
class Config:
    lzc_build_yaml: str
    manifest_yaml: str
    changelog: str

    def build(self, output: str = ""):
        try:
            # if "lzc-photo" in os.getcwd():
            #     exec("rm -rf ui/node_modules", True)
            #     exec("cd ui && ni", True)
            cmd = f"lzc-cli project build -f {self.lzc_build_yaml} "
            if output:
                cmd += f"-o {output}"
            exec(cmd, True)
        except:
            exec(f"git restore {self.manifest_yaml}")
            raise Exception("build error")

    def get_version(self):
        with open(self.manifest_yaml, "r") as f:
            contents = f.read()
        match = re.search(VERSION_PATTERN, contents)
        assert match, "未搜索到版本号"
        version = match.group(1)
        return version

    def update_version(self, increment=2):
        with open(self.manifest_yaml, "r") as f:
            contents = f.read()
        match = re.search(VERSION_PATTERN, contents)
        assert match, "未搜索到版本号"
        version = match.group(1)
        new_version = increment_version(version, increment)
        new_contents = re.sub(
            VERSION_PATTERN, f"version: {new_version}", contents)
        with open(self.manifest_yaml, "w") as f:
            f.write(new_contents)


CONFIG_PATH = "./lzc-project.json"
LPK_OUTPUT = "release.lpk"
VERSION_PATTERN = r"version:\s*([0-9]+\.[0-9]+\.[0-9]+)"

group = {
    2: "懒猫官方测试组",
    9000: "系统调试权限组",
    9001: "linakesi 公司内测组",
    9002: "linakesi 公司testing 组",
    9003: "内核测试组",
    9009: "小E调试组",
    9010: "Lzc AI 内测组",
    9011: "相册新数据库",
    9012: "向量数据库",
    9017: "相册测试组1"
}


def read_config():
    with open(CONFIG_PATH, "r") as f:
        return Config(**json.load(f))


def find_root(max_levels=3):
    current_dir = os.getcwd()
    levels = 0
    while levels < max_levels:
        if os.path.exists(os.path.join(current_dir, CONFIG_PATH)):
            return current_dir
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:
            break
        current_dir = parent_dir
        levels += 1
    return None


def check_health():
    root = find_root()
    assert root, "未检查到项目配置"
    os.chdir(root)


def exec(cmd: str, is_raise=False, text=False):
    print(cmd)
    try:
        if text:
            result = subprocess.run(cmd, shell=True, check=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        else:
            result = subprocess.run(cmd, shell=True, check=True)
        return result.stdout
    except:
        if is_raise:
            sys.exit(1)  # 停止程序的执行


def get_version(config: Config):
    with open(config.manifest_yaml, "r") as f:
        contents = f.read()
    match = re.search(VERSION_PATTERN, contents)
    assert match, "未搜索到版本号"
    version = match.group(1)
    return version


def increment_version(version: str, increment=2):
    version_parts = version.split('.')
    new_parts = int(version_parts[increment]) + 1
    version_parts[increment] = str(new_parts)
    return '.'.join(version_parts)


def edit_changelog():
    """ 更新Changelog """
    check_health()
    config = read_config()
    print("更新最近的commit到changelog")
    version = increment_version(config.get_version())
    exec(f"echo v{version} > temp.txt")
    # exec(
    #     'git log --oneline --format="%s" $(git describe --tags --abbrev=0)..HEAD >> temp.txt'
    # )
    exec(
        'git log --oneline --format="%s" $(git rev-list -n 1 $(git rev-list --tags --grep="appstore" --max-count=1) --grep="appstore")..HEAD >> temp.txt'
    )
    exec(f"cat {config.changelog} >> temp.txt")
    exec(f"cat temp.txt > {config.changelog}")
    exec("rm temp.txt")
    exec(f"sed -i 's/^fix/修复/g' {config.changelog}")
    exec(f"sed -i 's/^feat/新增/g' {config.changelog}")


def publish_current_version_to_store():
    check_health()
    config = read_config()
    print("发布到商店")
    with open(config.changelog, "r") as f:
        if "测试范围" in f.read():
            print("changelog 不标准!")
            return
    if not os.path.exists(LPK_OUTPUT):
        # update_version()
        config.build(LPK_OUTPUT)
    version = config.get_version()
    exec(f"git add {config.manifest_yaml}")
    exec(f"git add {config.changelog}")
    exec(f"git commit -m 'chore: appstore bump version {version}'")
    exec(f"git tag appstore-v{version} -f")
    exec(
        f"lzc-cli appstore publish {LPK_OUTPUT} --clangs zh:{config.changelog}", True)
    pyperclip.copy(f"已发布到懒猫商店: {version}")


def publish_to_testflight(groupId):
    check_health()
    config = read_config()
    groupId = groupId or 2
    print("发布到内测工具")
    config.update_version()
    config.build(LPK_OUTPUT)
    version = config.get_version()
    exec(f"git add {config.manifest_yaml}")
    exec(f"git add {config.changelog}")
    exec(f"git commit -m 'chore: testflight bump version {version}'")
    exec(f"git tag testflight-v{version} -f")
    cmd = f"lzc-cli appstore pre-publish {LPK_OUTPUT} -F {config.changelog}"
    if groupId:
        cmd += f" -G {groupId}"
    exec(cmd, True)
    msg = "已发布到内测工具"
    groupName = group.get(groupId, "")
    if groupName:
        msg += f"[{groupName}]"
    msg += f": {version}"
    pyperclip.copy(msg)


def download_log(log_id):
    try:
        # 密码: N5JKpyiw97zhrY0U
        url = f"https://hlogs.lazycat.cloud/api/v1/download-log/{log_id}"
        h = {
            "Authorization": "Basic bG5rczpONUpLcHlpdzk3emhyWTBV",
            "Cookie": "userToken=32ad3e6d0f2e47aba2d683942b5088b0"
        }
        print("下载日志: ", url)
        # 发送 GET 请求
        response = requests.get(url, headers=h)
        response.raise_for_status()  # 检查请求是否成功
        # 将内容写入文件
        path = os.path.join(os.getcwd(), f"{log_id}.zip")
        with open(path, 'wb') as file:
            file.write(response.content)
        print(f"下载成功")
        os.system(f"zsh -i -c 'x {path}'")
        print(f"解压成功")
        os.remove(path)
        print(f"移除zip")
    except requests.exceptions.RequestException as e:
        print(f"下载失败: {e}")


def build_install(yml_file="", box_name=None):
    originName = None
    if box_name:
        boxList = exec("lzc-cli box list", text=True, is_raise=True)
        if isinstance(boxList, str):
            if box_name in boxList:
                originName = exec("lzc-cli box default", text=True)
                exec(f"lzc-cli box switch {box_name}")
    print(yml_file)
    exec(f"lzc-cli project build -o release.lpk -f {yml_file}", is_raise=True)
    exec(f"lzc-cli app install release.lpk")
    exec(f"rm release.lpk")
    if originName:
        exec(f"lzc-cli box switch {originName}")
