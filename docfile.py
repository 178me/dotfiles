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

stow_list = [
    "vim", "zsh", "i3", "ranger", "alacritty", "git", "python", "ssh", "x11",
    "picom"
]
stow_sys_list = {"pacman": "-t /etc"}


def local_to_origin():
    """ 本地到远程 """
    input("将本机配置复制到仓库")
    for k, v in profile_list.items():
        # 处理家目录符号
        if os.path.exists(v):
            print(f"将本机配置复制到仓库: {k,os.path.basename(v)}")
            os.system(f"cp -rf {v} ./")


def origin_to_local():
    """ 更新本地文件 """
    # 获取当前目录下的配置
    input("将仓库配置复制到本机")
    now_config_list = os.listdir()
    for k, v in profile_list.items():
        if os.path.basename(v) in now_config_list:
            print(f"将仓库配置复制到本机: {k,os.path.basename(v)}")
            os.system(f"cp -rf {os.path.basename(v)} {os.path.dirname(v)}")


def show_stow_list():
    for k in stow_list:
        print(f'"{k}"', end=",")
    for k in stow_sys_list:
        print(f'"{k}"', end=",")


def stow_config():
    """ 更新本地文件 """
    # 获取当前目录下的配置
    input("stow所有应用")
    for k in stow_list:
        os.system(f"stow -v --adopt {k}")
    for k, v in stow_sys_list.items():
        os.system(f"sudo stow -v --adopt {v} {k}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(0)
    if sys.argv[1] == "push":
        local_to_origin()
    elif sys.argv[1] == "pull":
        origin_to_local()
    elif sys.argv[1] == "show":
        show_stow_list()
    elif sys.argv[1] == "stow":
        stow_config()
