#!/usr/bin/env python3
"""Capture installed tool metadata without collecting credentials or caches."""

import argparse
import datetime
import json
import os
import pathlib
import platform
import subprocess


TASK_HOME = pathlib.Path.home()
WARNINGS = []


def output(command, *, optional=False, env=()):
    try:
        result = subprocess.run(
            [str(arg) for arg in command], capture_output=True, text=True,
            env=os.environ | dict(env), timeout=120, check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        if not optional:
            raise RuntimeError(f"Cannot inspect {command[0]}: {error}") from error
        WARNINGS.append(f"Cannot inspect {command[0]}: {type(error).__name__}")
        return ""
    if result.returncode and not optional:
        raise RuntimeError(f"Inspection failed: {command!r}\n{result.stderr}")
    if result.returncode:
        WARNINGS.append(f"Inspection returned {result.returncode}: {command[0]}")
    return result.stdout.strip()


def lines(command):
    return sorted(output(command).splitlines())


def repo_info(path):
    return {
        "commit": output(["git", "-C", path, "rev-parse", "HEAD"]),
        "dirty": bool(output(["git", "-C", path, "status", "--porcelain"])),
    }


def dependencies(data, prefix):
    packages = []
    for name, entry in sorted(data.get("dependencies", {}).items()):
        path = prefix / "lib/node_modules" / name
        packages.append({
            "name": name, "version": entry.get("version", ""),
            "local_link": path.is_symlink(),
            "resolved": entry.get("resolved", ""),
        })
    return packages


def node_runtimes():
    root = TASK_HOME / ".asdf/installs/nodejs"
    runtimes = []
    if not root.is_dir():
        return runtimes
    for prefix in sorted(root.iterdir()):
        npm = prefix / "lib/node_modules/npm/bin/npm-cli.js"
        node = prefix / "bin/node"
        if not node.is_file() or not npm.is_file():
            WARNINGS.append(f"Incomplete Node runtime: {prefix.name}")
            continue
        raw = output([node, npm, "list", "--global", "--depth=0", "--json"],
                     optional=True, env={"PATH": f"{prefix}/bin:{os.environ['PATH']}"})
        if not raw:
            continue
        runtimes.append({"version": prefix.name,
                         "packages": dependencies(json.loads(raw), prefix)})
    return runtimes


def python_runtimes():
    prefixes = [("system", pathlib.Path("/usr/bin/python3"))]
    root = TASK_HOME / ".pyenv/versions"
    if root.is_dir():
        prefixes.extend((path.name, path / "bin/python") for path in sorted(root.iterdir())
                        if (path / "bin/python").is_file())
    runtimes = []
    for name, python in prefixes:
        raw = output([python, "-m", "pip", "list", "--format=json"], optional=True,
                     env={"PIP_DISABLE_PIP_VERSION_CHECK": "1", "PIP_NO_CACHE_DIR": "1"})
        runtimes.append({"name": name, "version": output([python, "--version"]),
                         "packages": json.loads(raw) if raw else []})
    return runtimes


def pnpm_globals():
    root = TASK_HOME / ".local/share/pnpm/global/5"
    manifest = root / "package.json"
    if not manifest.is_file():
        return []
    packages = []
    for name, requested in sorted(json.loads(manifest.read_text())["dependencies"].items()):
        path = root / "node_modules" / name
        package = path / "package.json"
        version = json.loads(package.read_text())["version"] if package.is_file() else ""
        resolved = path.resolve()
        packages.append({"name": name, "requested": requested, "version": version,
                         "local_link": not resolved.is_relative_to(root.resolve())})
    return packages


def go_tools():
    root = TASK_HOME / "go/bin"
    tools = []
    if not root.is_dir():
        return tools
    for binary in sorted(root.iterdir()):
        if not binary.is_file():
            continue
        raw = output(["go", "version", "-m", binary], optional=True)
        entry = {"binary": binary.name, "package": "", "module": "", "version": ""}
        for line in raw.splitlines():
            fields = line.split()
            if len(fields) >= 2 and fields[0] == "path":
                entry["package"] = fields[1]
            if len(fields) >= 3 and fields[0] == "mod":
                entry.update(module=fields[1], version=fields[2])
        tools.append(entry)
    return tools


def capture():
    asdf_root = TASK_HOME / ".asdf"
    asdf = asdf_root / "bin/asdf"
    repos = [
        ("oh-my-zsh", TASK_HOME / ".oh-my-zsh", "https://github.com/ohmyzsh/ohmyzsh.git"),
        ("zsh-syntax-highlighting", TASK_HOME / ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting",
         "https://github.com/zsh-users/zsh-syntax-highlighting.git"),
        ("zsh-autosuggestions", TASK_HOME / ".oh-my-zsh/custom/plugins/zsh-autosuggestions",
         "https://github.com/zsh-users/zsh-autosuggestions.git"),
        ("asdf", asdf_root, "https://github.com/asdf-vm/asdf.git"),
        ("asdf-nodejs", asdf_root / "plugins/nodejs", "https://github.com/asdf-vm/asdf-nodejs.git"),
    ]
    git_repos = {name: repo_info(path) | {"url": url}
                 for name, path, url in repos if (path / ".git").exists()}
    installed = [dict(zip(("name", "version"), line.split(maxsplit=1)))
                 for line in lines(["pacman", "-Q"])]
    tool_versions = TASK_HOME / ".tool-versions"
    uv_root = TASK_HOME / ".local/share/uv/tools"
    uv_tools = sorted(p.name for p in uv_root.iterdir() if p.is_dir()) if uv_root.is_dir() else []
    cargo = TASK_HOME / ".cargo/.crates2.json"
    cargo_tools = json.loads(cargo.read_text()).get("installs", {}) if cargo.is_file() else {}
    return {
        "schema_version": 1,
        "captured_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "source": {"hostname": platform.node(), "architecture": platform.machine()},
        "arch": {"installed": installed, "explicit_repo": lines(["pacman", "-Qqen"]),
                 "explicit_foreign": lines(["pacman", "-Qqem"])},
        "git_repositories": git_repos,
        "asdf": {"version": output([asdf, "--version"]),
                 "tool_versions": tool_versions.read_text() if tool_versions.is_file() else ""},
        "node": {"runtimes": node_runtimes(), "pnpm_globals": pnpm_globals()},
        "python": {"pyenv_version": output(["pyenv", "--version"]),
                   "global": output(["pyenv", "global"]).splitlines(),
                   "runtimes": python_runtimes()},
        "go": {"version": output(["go", "version"]), "tools": go_tools()},
        "uv_tool_names": uv_tools, "cargo_tool_ids": sorted(cargo_tools),
        "warnings": WARNINGS,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=pathlib.Path)
    args = parser.parse_args()
    text = json.dumps(capture(), ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text)
        print(f"Snapshot saved: {args.output}")
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
