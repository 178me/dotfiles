#!/usr/bin/env python3
"""Regenerate pnpm global command launchers after relocating installed packages."""

import json
import pathlib
import re
import shlex


home = pathlib.Path.home()
pnpm_home = home / ".local/share/pnpm"
modules = pnpm_home / "global/5/node_modules"
marker = "# Managed by dotfiles relink-pnpm.py\n"
packages = []
for entry in modules.iterdir():
    if entry.name.startswith("."):
        continue
    if entry.name.startswith("@"):
        packages.extend(entry.iterdir())
    else:
        packages.append(entry)
for package in packages:
    metadata = json.loads((package / "package.json").read_text())
    bins = metadata.get("bin", {})
    if isinstance(bins, str):
        bins = {metadata["name"].split("/")[-1]: bins}
    for name, relative in bins.items():
        if not re.fullmatch(r"[A-Za-z0-9._-]+", name):
            raise ValueError(f"Unsafe command name: {name}")
        source = (package / relative).resolve()
        source.relative_to(pnpm_home)
        if not source.is_file():
            raise FileNotFoundError(source)
        target = pnpm_home / name
        if target.is_symlink() or (target.exists() and marker not in target.read_text(errors="replace")):
            raise RuntimeError(f"Refusing to replace existing launcher: {target}")
        target.write_text("#!/bin/sh\n" + marker + f"exec {shlex.quote(str(source))} \"$@\"\n")
        target.chmod(0o755)
        print(f"LINK {name}: {metadata['name']}@{metadata['version']}")
