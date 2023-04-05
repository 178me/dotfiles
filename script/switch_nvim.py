import sys
import os

home_dir = os.path.expanduser("~")
nvim_config = ""
nvim_root = ""
if sys.argv[1] == "178me":
    nvim_config = os.path.join(home_dir, "docfiles", "nvim-178me", ".config",
                               "nvim")
    nvim_root = os.path.join(home_dir, "docfiles", "nvim-root", "nvim-178me")
elif sys.argv[1] == "lazy":
    nvim_config = os.path.join(home_dir, "docfiles", "nvim-lazy", ".config",
                               "nvim")
    nvim_root = os.path.join(home_dir, "docfiles", "nvim-root", "nvim-lazy")
# elif sys.argv[1] == "diy":
#     nvim_config = "/home/yzl178me/temp/nvim_config/nvim.diy"
#     nvim_root = "/home/yzl178me/temp/diy/nvim"

os.system("rm -rf ~/.config/nvim")
os.system("rm -rf ~/.local/share/nvim")
os.system(f"ln -s {nvim_config} " + os.path.join(home_dir, ".config", "nvim"))
os.system(f"ln -s {nvim_root} " +
          os.path.join(home_dir, ".local", "share", "nvim"))
