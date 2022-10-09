""" link profile """
import os
import sys

HOME = os.environ["HOME"]
profile_list = {
    "窗口管理器": f"{HOME}/.config/i3",
    "文件管理器": f"{HOME}/.config/ranger",
    "虚拟终端": f"{HOME}/.config/alacritty",
    "编辑器": f"{HOME}/.config/nvim",
    "窗口渲染": f"{HOME}/.config/picom.conf",
    "X11配置": f"{HOME}/.xprofile",
    "包管理器": "/etc/pacman.conf",
    "pip": f"{HOME}/.pip/pip.conf",
    "shell": f"{HOME}/.zshrc",
    "git": f"{HOME}/.gitconfig",
    "ssh": f"{HOME}/.ssh/config",
}


def local_to_origin():
    """ 本地到远程 """
    for k, v in profile_list.items():
        # 处理家目录符号
        if os.path.exists(v):
            print(f"将本机配置复制到仓库: {k,os.path.basename(v)}")
            os.system(f"cp -rf {v} ./")


def origin_to_local():
    """ 更新本地文件 """
    # 获取当前目录下的配置
    now_config_list = os.listdir()
    for k, v in profile_list.items():
        if os.path.basename(v) in now_config_list:
            print(f"将仓库配置复制到本机: {k,os.path.basename(v)}")
            os.system(f"cp -rf {os.path.basename(v)} {os.path.dirname(v)}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(0)
    if sys.argv[1] == "push":
        local_to_origin()
    elif sys.argv[1] == "pull":
        origin_to_local()
