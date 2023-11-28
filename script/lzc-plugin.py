#!/usr/bin/env python3

import subprocess
import pyperclip
import requests
import argparse
import json
import re
import os
import sys
from dataclasses import dataclass


@dataclass
class Config:
    lzc_build_yaml: str
    manifest_yaml: str
    changelog: str


CONFIG_PATH = "./lzc-project.json"
LPK_OUTPUT = "release.lpk"
VERSION_PATTERN = r"version:\s*([0-9]+\.[0-9]+\.[0-9]+)"


def read_config():
    with open(CONFIG_PATH, "r") as f:
        return Config(**json.load(f))


def check_health():
    assert os.path.exists(CONFIG_PATH), "未检查到项目配置"


def exec(cmd: str, is_raise=False):
    print(cmd)
    try:
        subprocess.run(cmd, shell=True, check=True)
    except:
        if is_raise:
            sys.exit(1)  # 停止程序的执行


def get_version():
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


def update_version(increment=2):
    with open(config.manifest_yaml, "r") as f:
        contents = f.read()
    match = re.search(VERSION_PATTERN, contents)
    assert match, "未搜索到版本号"
    version = match.group(1)
    new_version = increment_version(version, increment)
    new_contents = re.sub(VERSION_PATTERN, f"version: {new_version}", contents)
    with open(config.manifest_yaml, "w") as f:
        f.write(new_contents)


def build(output: str = ""):
    cmd = f"lzc-cli project build -f {config.lzc_build_yaml} "
    if output:
        cmd += f"-o {output}"
    exec(cmd, True)


def edit_changelog():
    """ 更新Changelog """
    print("更新最近的commit到changelog")
    version = increment_version(get_version())
    exec(f"echo v{version} > temp.txt")
    exec(
        'git log --oneline --format="%s" $(git describe --tags --abbrev=0)..HEAD >> temp.txt'
    )
    exec(f"cat {config.changelog} >> temp.txt")
    exec(f"cat temp.txt > {config.changelog}")
    exec("rm temp.txt")
    exec(f"sed -i 's/^fix/修复/g' {config.changelog}")
    exec(f"sed -i 's/^feat/新增/g' {config.changelog}")


def check_token():
    auth = os.environ["TestFlight_Authorization"]
    assert auth, "请将testflight认证设置到环境变量TestFlight_Authorization"
    url = "https://testflight.lazycat.cloud/api/groups/dict"
    headers = {
        "Authorization":
        auth,
        "user-agent":
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
    }
    resp = requests.get(url, headers=headers)
    return resp.status_code < 400


def upload_to_testflight(groupId=2):
    auth = os.environ["TestFlight_Authorization"]
    assert auth, "请将testflight认证设置到环境变量TestFlight_Authorization"
    url = f"https://testflight.lazycat.cloud/api/group/{groupId}/upload"
    headers = {
        "Authorization":
        auth,
        "user-agent":
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
    }
    with open(config.changelog, "r") as f:
        changelog = f.read()
    data = {
        "type": (None, "Lpk"),
        "changelog": (None, changelog),
        "file": ("release.lpk", open("release.lpk",
                                     "rb"), "application/octet-stream"),
    }
    resp = requests.post(url, headers=headers, files=data)
    print(resp.text)
    return resp.status_code < 400


def publish_current_version_to_store():
    print("发布到商店")
    if not os.path.exists(LPK_OUTPUT):
        update_version()
        build(LPK_OUTPUT)
    version = get_version()
    exec(f"git add {config.manifest_yaml}")
    exec(f"git add {config.changelog}")
    exec(f"git commit -m 'chore: bump version {version}'")
    exec(f"git tag appstore-v{version}")
    exec(f"lzc-cli appstore publish {LPK_OUTPUT} -F {config.changelog}", True)
    pyperclip.copy(f"已发布到懒猫商店: {version}")


def publish_to_testflight():
    print("发布到内测工具")
    if not check_token():
        print("token 可能已过期!")
        return
    update_version()
    build(LPK_OUTPUT)
    version = get_version()
    exec(f"git add {config.manifest_yaml}")
    exec(f"git add {config.changelog}")
    exec(f"git commit -m 'chore: bump version {version}'")
    exec(f"git tag testflight-v{version} -f")
    upload_to_testflight()
    pyperclip.copy(f"已发布到内测工具: {version}")


def main():
    parser = argparse.ArgumentParser(
        description="Command line tool for publishing")
    subparsers = parser.add_subparsers(title="subcommands", dest="subcommand")

    # Subparser for "publish" command
    publish_parser = subparsers.add_parser("p", help="Publish to destination")
    publish_parser.add_argument("destination",
                                choices=["appstore", "testflight"],
                                help="Destination to publish")
    # Subparser for "edit" command
    edit_parser = subparsers.add_parser("e", help="Edit changelog file")
    edit_parser.add_argument("chg", help="Changelog file to edit")

    args = parser.parse_args()

    if args.subcommand == "p":
        if args.destination == "appstore":
            publish_current_version_to_store()
        elif args.destination == "testflight":
            publish_to_testflight()
    elif args.subcommand == "e":
        edit_changelog()
    else:
        parser.print_help()


if __name__ == "__main__":
    check_health()
    config = read_config()
    main()
