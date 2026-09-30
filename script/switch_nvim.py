#!/usr/bin/env python3
"""Select a rendered Neovim config while preserving plugins and previous config."""

import argparse
import pathlib
import subprocess
import tempfile


def select_profile(profile):
    task_home = pathlib.Path.home()
    repo = pathlib.Path(__file__).resolve().parent.parent
    config = task_home / ".config" / f"nvim-{profile}"
    if not config.is_dir():
        subprocess.run(["chezmoi", "-S", str(repo), "apply", str(config)], check=True)
    active = task_home / ".config/nvim"
    if active.is_symlink() and active.resolve() == config.resolve():
        print(f"Already selected: {config}")
        return

    backups = task_home / ".local/state/dotfiles/backups"
    backups.mkdir(parents=True, exist_ok=True)
    backup = pathlib.Path(tempfile.mkdtemp(prefix="nvim-switch-", dir=backups))
    backup.chmod(0o700)
    had_previous = active.exists() or active.is_symlink()
    if had_previous:
        active.rename(backup / "nvim.previous")
    try:
        active.symlink_to(config, target_is_directory=True)
    except OSError:
        if had_previous:
            (backup / "nvim.previous").rename(active)
        raise
    print(f"Selected: {config}")
    print(f"Previous config backup: {backup}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", choices=["178me", "lazy"])
    select_profile(parser.parse_args().profile)


if __name__ == "__main__":
    main()
