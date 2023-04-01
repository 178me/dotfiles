import sys
import os

nvim_config = ""
nvim_root = ""
if sys.argv[1] == "178me":
    nvim_config = "/home/yzl178me/temp/nvim_config/nvim.178me"
    nvim_root = "/home/yzl178me/temp/178me/nvim"
elif sys.argv[1] == "lazy":
    nvim_config = "/home/yzl178me/temp/nvim_config/nvim.lazy"
    nvim_root = "/home/yzl178me/temp/lazy/nvim"
elif sys.argv[1] == "diy":
    nvim_config = "/home/yzl178me/temp/nvim_config/nvim.diy"
    nvim_root = "/home/yzl178me/temp/diy/nvim"

os.system("rm -rf ~/.config/nvim")
os.system("rm -rf ~/.local/share/nvim")
os.system(f"ln -s {nvim_config} /home/yzl178me/.config/nvim")
os.system(f"ln -s {nvim_root} /home/yzl178me/.local/share/nvim")
