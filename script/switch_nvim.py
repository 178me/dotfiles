import sys
import os
from pathlib import Path

home_dir = os.path.expanduser("~")
repo_dir = Path(__file__).resolve().parent.parent
nvim_config = ""
nvim_root = ""
if sys.argv[1] == "178me":
    nvim_config = str(repo_dir / "home" / "dot_config" / "nvim-178me")
    nvim_root = str(repo_dir / "nvim-root" / "nvim-178me")
elif sys.argv[1] == "lazy":
    nvim_config = str(repo_dir / "home" / "dot_config" / "nvim-lazy")
    nvim_root = str(repo_dir / "nvim-root" / "nvim-lazy")
# elif sys.argv[1] == "diy":
#     nvim_config = "/home/yzl178me/temp/nvim_config/nvim.diy"
#     nvim_root = "/home/yzl178me/temp/diy/nvim"

os.system("rm -rf ~/.config/nvim")
os.system("rm -rf ~/.local/share/nvim")
print(f"ln -s {nvim_config} " + os.path.join(home_dir, ".config", "nvim"))
os.system(f"ln -s {nvim_config} " + os.path.join(home_dir, ".config", "nvim"))
print(f"ln -s {nvim_root} " +
          os.path.join(home_dir, ".local", "share", "nvim"))
os.system(f"ln -s {nvim_root} " +
          os.path.join(home_dir, ".local", "share", "nvim"))
