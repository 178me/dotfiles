#!/usr/bin/env python3
"""Extract hash-verified Arch CLI packages into HOME, without pacman writes."""

import argparse
import concurrent.futures
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
import urllib.parse

from restore import package_list, REPO


HOME = pathlib.Path.home()
PREFIX = HOME / ".local/opt/dotfiles-cli"
CACHE = HOME / ".cache/dotfiles/packages"
BIN = HOME / ".local/bin"
MARKER = "# Managed by dotfiles user_packages.py\n"


def resolve():
    output = subprocess.check_output([
        "pacman", "-Sp", "--needed", "--print-format", "%n|%v|%l|%h",
        *package_list(REPO / "packages/arch-user-cli.txt"),
    ], text=True)
    packages = []
    for line in output.splitlines():
        name, version, url, digest = line.split("|")
        if urllib.parse.urlsplit(url).scheme != "https" or not re.fullmatch(r"[0-9a-f]{64}", digest):
            raise ValueError(f"Expected HTTPS URL and repository SHA-256: {name}")
        packages.append(dict(name=name, version=version, url=url, sha256=digest))
    return packages


def fetch(package):
    target = CACHE / pathlib.PurePosixPath(urllib.parse.urlsplit(package["url"]).path).name
    if not target.exists():
        partial = target.with_name(target.name + ".partial")
        archive_url = (f"https://archive.archlinux.org/packages/{package['name'][0]}/"
                       f"{package['name']}/{urllib.parse.quote(target.name)}")
        for url in (package["url"], archive_url):
            result = subprocess.run([
                "curl", "--fail", "--location", "--silent", "--show-error", "--retry", "3",
                "--connect-timeout", "15", "--max-time", "600", "--proto", "=https",
                "--proto-redir", "=https", "--output", str(partial), url,
            ])
            if result.returncode == 0:
                break
        else:
            raise RuntimeError(f"Cannot download repository or official archive package: {package['name']}")
        with partial.open("rb") as stream:
            if hashlib.file_digest(stream, "sha256").hexdigest() != package["sha256"]:
                raise RuntimeError(f"Package hash mismatch: {package['name']}")
        partial.replace(target)
    with target.open("rb") as stream:
        if hashlib.file_digest(stream, "sha256").hexdigest() != package["sha256"]:
            raise RuntimeError(f"Cached package hash mismatch: {target}")
    print(f"VERIFIED {package['name']} {package['version']}", flush=True)
    return target


def wrapper(source):
    lines = ["#!/bin/sh\n", MARKER,
             f"export LD_LIBRARY_PATH={shlex.quote(str(PREFIX / 'usr/lib'))}${{LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}}\n"]
    python_paths = sorted((PREFIX / "usr/lib").glob("python*/site-packages"))
    if python_paths:
        paths = ":".join(map(str, python_paths))
        lines.append(f"export PYTHONPATH={shlex.quote(paths)}${{PYTHONPATH:+:$PYTHONPATH}}\n")
    if source.name == "nvim":
        lines += [f"export VIMRUNTIME={shlex.quote(str(PREFIX / 'usr/share/nvim/runtime'))}\n",
                  f"export LUA_CPATH={shlex.quote(str(PREFIX / 'usr/lib/lua/5.1/?.so') + ';;')}\n"]
    if source.name == "ranger":
        lines.append(f"export RANGER_SHARE_DIR={shlex.quote(str(PREFIX / 'usr/share/ranger'))}\n")
    lines.append(f"exec {shlex.quote(str(source))} \"$@\"\n")
    return "".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    packages = resolve()
    for package in packages:
        print(f"PACKAGE {package['name']} {package['version']}", flush=True)
    if not args.apply:
        print(f"Preview only. Destination: {PREFIX}")
        return
    for directory in (CACHE, PREFIX, BIN):
        directory.mkdir(parents=True, exist_ok=True)
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        archives = list(pool.map(fetch, packages))
    for archive in archives:
        members = subprocess.check_output(["bsdtar", "-tf", str(archive)], text=True).splitlines()
        if any(pathlib.PurePosixPath(member).is_absolute() or ".." in pathlib.PurePosixPath(member).parts
               for member in members):
            raise RuntimeError(f"Unsafe archive paths: {archive}")
        # No scriptlets, services, /etc writes, or package database changes.
        subprocess.run(["bsdtar", "-xf", str(archive), "-C", str(PREFIX), "usr/"], check=True)
    for path in (PREFIX / "usr").rglob("*"):
        if path.is_symlink() and str(path.readlink()).startswith("/usr/"):
            relocated = PREFIX / str(path.readlink()).lstrip("/")
            if relocated.exists():
                path.unlink()
                path.symlink_to(relocated)
    # Arch Neovim links lpeg by absolute path; relocate that ELF dependency.
    nvim = PREFIX / "usr/bin/nvim"
    patchelf = PREFIX / "usr/bin/patchelf"
    needed = subprocess.check_output([str(patchelf), "--print-needed", str(nvim)], text=True).splitlines()
    for library in needed:
        if library.startswith("/usr/"):
            relocated = PREFIX / library.lstrip("/")
            if not relocated.is_file():
                raise FileNotFoundError(relocated)
            subprocess.run([str(patchelf), "--replace-needed", library, str(relocated), str(nvim)], check=True)
    sources = list((PREFIX / "usr/bin").iterdir())
    sources += [pathlib.Path("/usr/bin/python"), pathlib.Path("/usr/bin/python3")]
    java_bin = PREFIX / "usr/lib/jvm/java-17-openjdk/bin"
    if java_bin.is_dir():
        sources += list(java_bin.iterdir())
    for source in sources:
        if not source.is_file():
            continue
        destination = BIN / source.name
        if destination.is_symlink() or (destination.exists() and MARKER not in destination.read_text(errors="replace")):
            raise RuntimeError(f"Refusing to replace existing user command: {destination}")
        destination.write_text(wrapper(source))
        destination.chmod(0o755)
    (PREFIX / "packages.json").write_text(json.dumps(packages, indent=2) + "\n")
    print(f"Installed {len(packages)} packages under {PREFIX}; prepend {BIN} to PATH.")


if __name__ == "__main__":
    main()
