#!/usr/bin/env python3
"""Preview or install shared tools from an inspected Arch environment snapshot."""

import argparse
import json
import os
import pathlib
import re
import shlex
import subprocess


REPO = pathlib.Path(__file__).resolve().parents[2]
TASK_HOME = pathlib.Path.home()


def package_list(path):
    return [line.split("#", 1)[0].strip() for line in path.read_text().splitlines()
            if line.split("#", 1)[0].strip()]


class Installer:
    def __init__(self, apply):
        self.apply = apply
        self.env = os.environ | {
            "ASDF_DIR": str(TASK_HOME / ".asdf"),
            "ASDF_DATA_DIR": str(TASK_HOME / ".asdf"),
            "PYENV_ROOT": str(TASK_HOME / ".pyenv"),
            "PNPM_HOME": str(TASK_HOME / ".local/share/pnpm"),
            "GOBIN": str(TASK_HOME / "go/bin"),
        }

    def run(self, command, **kwargs):
        command = [str(arg) for arg in command]
        print(("RUN " if self.apply else "PLAN ") + shlex.join(command), flush=True)
        if self.apply:
            subprocess.run(command, check=True, env=self.env, **kwargs)

    def validate_checkout(self, entry, target):
        commit = entry["commit"]
        if entry["dirty"]:
            raise RuntimeError(f"Source repository has uncommitted changes: {target}")
        if not re.fullmatch(r"[0-9a-f]{40}", commit):
            raise ValueError(f"Invalid pinned commit: {commit}")
        if target.exists():
            current = subprocess.check_output(
                ["git", "-C", str(target), "rev-parse", "HEAD"], text=True).strip()
            if current != commit:
                raise RuntimeError(f"Existing {target} has a different commit; keep it and reconcile manually")

    def checkout(self, entry, target):
        self.validate_checkout(entry, target)
        commit = entry["commit"]
        if target.exists():
            print(f"KEEP {target} ({commit[:12]})")
            return
        # Public tool sources must work before SSH keys or Git config are restored.
        git = ["env", "GIT_CONFIG_GLOBAL=/dev/null", "GIT_CONFIG_NOSYSTEM=1", "git"]
        self.run([*git, "init", target])
        self.run([*git, "-C", target, "remote", "add", "origin", entry["url"]])
        self.run([*git, "-C", target, "fetch", "--depth", "1", "origin", commit])
        self.run([*git, "-C", target, "checkout", "--detach", commit])


def restore(args, snapshot):
    installer = Installer(args.apply)
    packages = package_list(REPO / "packages/arch-cli.txt")
    if args.desktop:
        packages += package_list(REPO / "packages/arch-desktop.txt")
    if args.all_runtimes:
        packages += package_list(REPO / "packages/arch-python-build.txt")
    repos = snapshot["git_repositories"]
    targets = {
        "oh-my-zsh": TASK_HOME / ".oh-my-zsh",
        "zsh-syntax-highlighting": TASK_HOME / ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting",
        "zsh-autosuggestions": TASK_HOME / ".oh-my-zsh/custom/plugins/zsh-autosuggestions",
        "asdf": TASK_HOME / ".asdf",
        "asdf-nodejs": TASK_HOME / ".asdf/plugins/nodejs",
    }
    asdf = TASK_HOME / ".asdf/bin/asdf"
    selected = snapshot["asdf"]["tool_versions"].split()
    if len(selected) != 2 or selected[0] != "nodejs":
        raise ValueError("Expected one global nodejs version in the saved .tool-versions")
    active_node = selected[1]
    runtimes = snapshot["node"]["runtimes"]
    if active_node not in {runtime["version"] for runtime in runtimes}:
        raise ValueError("Selected Node runtime is missing from the snapshot")
    for name, target in targets.items():
        installer.validate_checkout(repos[name], target)
    # Arch requires a full upgrade when refreshing repository metadata.
    if args.skip_system_packages:
        print("SKIP system packages (must already be installed)")
    else:
        installer.run(["sudo", "pacman", "-Syu", "--needed", *sorted(set(packages))])
    for name, target in targets.items():
        installer.checkout(repos[name], target)
    versions = [entry["version"] for entry in runtimes] if args.all_runtimes else [active_node]
    for version in versions:
        installer.run(["bash", asdf, "install", "nodejs", version])
    # Set the default only on a new device; don't replace an existing selection.
    versions_file = TASK_HOME / ".tool-versions"
    if versions_file.exists():
        print(f"KEEP existing {versions_file}; requested default: nodejs {active_node}")
    else:
        installer.run(["bash", asdf, "global", "nodejs", active_node])
    node_bin = TASK_HOME / f".asdf/installs/nodejs/{active_node}/bin"
    installer.env["PATH"] = f"{node_bin}:{installer.env['PATH']}"
    if args.all_runtimes:
        for runtime in snapshot["python"]["runtimes"]:
            if runtime["name"] != "system":
                installer.run(["/usr/bin/pyenv", "install", "-s", runtime["name"]])
    if args.language_tools:
        active_path = installer.env["PATH"]
        for runtime in runtimes:
            if runtime["version"] not in versions:
                continue
            prefix = TASK_HOME / f".asdf/installs/nodejs/{runtime['version']}"
            installer.env["PATH"] = f"{prefix}/bin:{active_path}"
            node = prefix / "bin/node"
            npm = prefix / "lib/node_modules/npm/bin/npm-cli.js"
            specs = []
            for package in runtime["packages"]:
                if package["local_link"]:
                    print(f"MANUAL local npm link: {package['name']} ({package['resolved']})")
                else:
                    specs.append(f"{package['name']}@{package['version']}")
            if specs:
                installer.run([node, npm, "install", "--global", "--", *specs])
        installer.env["PATH"] = active_path
        pnpm_specs = []
        for package in snapshot["node"]["pnpm_globals"]:
            if package["local_link"] or not package["version"]:
                print(f"MANUAL pnpm dependency: {package['name']}")
            else:
                pnpm_specs.append(f"{package['name']}@{package['version']}")
        if pnpm_specs:
            installer.env["PATH"] = f"{installer.env['PNPM_HOME']}:{installer.env['PATH']}"
            installer.run([node_bin / "pnpm", "add", "--global", "--", *pnpm_specs])
        for tool in snapshot["go"]["tools"]:
            if not tool["version"].startswith("v") or not tool["package"]:
                print(f"MANUAL Go tool: {tool['binary']} ({tool['version']})")
            else:
                installer.run(["go", "install", f"{tool['package']}@{tool['version']}"])
        installer.run(["bash", asdf, "reshim", "nodejs"])

    print("\nTools only: review machine-specific dotfiles before chezmoi apply.")
    print("No config apply, default-shell change, service enablement or Docker group change was performed.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Install tools (default: preview only)")
    parser.add_argument("--skip-system-packages", action="store_true", help="Resume user tools after pacman was run separately")
    parser.add_argument("--desktop", action="store_true", help="Include optional desktop tools")
    parser.add_argument("--all-runtimes", action="store_true", help="Include all saved Node and pyenv versions")
    parser.add_argument("--language-tools", action="store_true", help="Restore registry npm/pnpm and versioned Go tools")
    parser.add_argument("--snapshot", type=pathlib.Path, default=REPO / "packages/snapshots/local.json")
    args = parser.parse_args()
    if args.apply and os.geteuid() == 0:
        parser.error("Run as the target user; only pacman uses sudo")
    if args.apply and not pathlib.Path("/etc/arch-release").is_file():
        parser.error("This installer supports Arch Linux only")
    snapshot = json.loads(args.snapshot.read_text())
    if snapshot["schema_version"] != 1:
        parser.error("Unsupported snapshot schema")
    restore(args, snapshot)


if __name__ == "__main__":
    main()
