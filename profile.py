""" link profile """
import os

HOME = os.environ["HOME"]
profile_list = {
    "窗口管理器": f"{HOME}/.config/i3",
    "虚拟终端": f"{HOME}/.config/alacritty",
    "编辑器": f"{HOME}/.config/nvim",
    "窗口渲染": f"{HOME}/.config/picom.conf",
    "X11配置": f"{HOME}/.xprofile",
    "包管理器": f"/etc/pacman.conf",
    "pip": f"{HOME}/.pip/pip.conf",
    "shell": f"{HOME}/.zshrc",
}


def local_to_origin():
    """ 本地到远程 """
    for k,v in profile_list.items():
        print(k,v)
        # 处理家目录符号
        if os.path.exists(v):
            print(f"正在复制配置到当前文件夹: {k}")
            os.system(f"cp -rf {v} ./")

def origin_to_local():
    """ 更新本地文件 """
    # 获取当前目录下的配置
    now_config_list = os.listdir()
    for k,v in profile_list.items():
        print(k,v)
        if os.path.basename(v) in now_config_list:
            print(f"正在复制配置到本地: {k}")
            os.system(f"cp -rf {os.path.basename(v)} {v}")


if __name__ == "__main__":
    # local_to_origin()
    origin_to_local()
