#!/usr/bin/env python3
"""Relocate installed Mason launchers after copying an existing tool directory."""

import argparse
import pathlib


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source-home", required=True, type=pathlib.Path)
args = parser.parse_args()
if not args.source_home.is_absolute():
    parser.error("--source-home must be absolute")
mason = pathlib.Path.home() / ".local/share/nvim/mason"
old_roots = [args.source_home / ".local/share/nvim/mason",
             args.source_home / ".config/nvim-profiles/178me-lazy/share/mason"]
for launcher in (mason / "bin").iterdir():
    source = launcher.resolve(strict=True)
    source.relative_to(mason)
    data = source.read_bytes()
    if not data.startswith(b"#!"):
        continue
    content = data.decode("utf-8")
    updated = content
    for old_root in old_roots:
        updated = updated.replace(str(old_root), str(mason))
    if updated != content:
        source.write_text(updated)
        print(f"RELOCATED {launcher.name}")
