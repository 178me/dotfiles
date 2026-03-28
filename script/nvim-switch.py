#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from typing import Dict
import shutil
import click


class NeovimProfileSwitcher:
    # 硬编码的根目录（可根据需要修改）
    ROOT_DIR = Path.home() / ".config" / "nvim-profiles"

    # 定义需要管理的链接目标
    LINK_TARGETS = {
        'config': Path('~/.config/nvim').expanduser(),
        'share': Path('~/.local/share/nvim').expanduser(),
    }

    # 需要删除的目录（不进行链接）
    REMOVE_TARGETS = {
        'state': Path('~/.local/state/nvim').expanduser(),
        'cache': Path('~/.cache/nvim').expanduser()
    }

    def __init__(self):
        self.ensure_root_dir()

    def ensure_root_dir(self):
        """确保根目录存在"""
        self.ROOT_DIR.mkdir(parents=True, exist_ok=True)

    def list_profiles(self) -> Dict[str, Path]:
        """列出所有可用的配置profile"""
        return {
            p.name: p for p in self.ROOT_DIR.iterdir()
            if p.is_dir() and not p.name.startswith('.')
        }

    def switch_profile(self, profile: str):
        """切换到指定profile"""
        profile_dir = self.ROOT_DIR / profile

        # 验证目录结构
        self.validate_profile_structure(profile_dir)

        # 切换所有链接
        for link_type, system_path in self.LINK_TARGETS.items():
            source = profile_dir / link_type

            # 删除现有链接或目录
            if system_path.exists():
                if system_path.is_symlink():
                    system_path.unlink()
                else:
                    click.echo(f"警告: {system_path} 是真实目录，将被覆盖")
                    shutil.rmtree(system_path)

            # 创建符号链接
            os.symlink(source, system_path, target_is_directory=True)
            click.echo(f"Linked: {system_path} -> {source}")

        # 删除state和cache目录（如果存在）
        for remove_type, system_path in self.REMOVE_TARGETS.items():
            if system_path.exists():
                if system_path.is_symlink():
                    system_path.unlink()
                    click.echo(f"Removed symlink: {system_path}")
                else:
                    shutil.rmtree(system_path)
                    click.echo(f"Removed directory: {system_path}")

        click.echo(f"\n✅ 已切换到 profile: {profile}")
        click.echo(f"配置文件目录: {profile_dir}/config")
        click.echo(f"数据文件目录: {profile_dir}/share")

    def validate_profile_structure(self, profile_dir: Path):
        """验证profile目录结构"""
        required = ['config', 'share']  # 必要目录
        missing = [d for d in required if not (profile_dir / d).exists()]

        if missing:
            raise ValueError(
                f"Profile目录结构不完整，缺少: {missing}\n"
                f"要求的目录结构:\n"
                f"{profile_dir.name}/\n"
                f"├── config/  (必须)\n"
                f"├── share/   (必须)\n"
                f"├── state/   (可选，会被删除)\n"
                f"└── cache/   (可选，会被删除)"
            )


@click.group()
def cli():
    """Neovim Profile Switcher - 管理多个Neovim配置profile"""
    pass


@cli.command()
def list():
    """列出所有可用的profile"""
    switcher = NeovimProfileSwitcher()
    profiles = switcher.list_profiles()

    if not profiles:
        click.echo(f"没有找到任何profile，请在 {switcher.ROOT_DIR} 下创建")
        click.echo("示例目录结构:")
        click.echo("  nvim_profiles/")
        click.echo("  └── your_profile/")
        click.echo("      ├── config/")
        click.echo("      └── share/")
        return

    click.echo(f"可用 profiles (位于 {switcher.ROOT_DIR}):")
    for name in profiles:
        click.echo(f"  - {name}")


@cli.command()
@click.argument('profile')
def switch(profile):
    """切换到指定profile"""
    switcher = NeovimProfileSwitcher()
    try:
        switcher.switch_profile(profile)
    except Exception as e:
        click.echo(f"错误: {e}", err=True)
        sys.exit(1)


if __name__ == "__main__":
    cli()
