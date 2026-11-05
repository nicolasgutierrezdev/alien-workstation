#!/usr/bin/env python3
"""Build PACKAGES.md (a readable, categorized package list) from packages/*.txt.

Descriptions come from the local pacman database, so this needs no network.
"""
import pathlib
import re
import subprocess

REPO = pathlib.Path(__file__).resolve().parent.parent
PKG = REPO / "packages"


def parse(path):
    """Yield (category, name, note) from a package list file."""
    category = None
    for line in path.read_text().splitlines():
        if line.startswith("## "):
            category = line[3:].strip()
            continue
        name, _, note = line.partition("#")
        name = name.strip()
        if name:
            yield category, name, note.strip()


def descriptions(names):
    out = {}
    for flag in ("-Qi", "-Si"):
        missing = [n for n in names if n not in out]
        if not missing:
            break
        res = subprocess.run(["pacman", flag, *missing], capture_output=True, text=True)
        current = None
        for line in res.stdout.splitlines():
            if m := re.match(r"^Name\s+:\s+(\S+)", line):
                current = m.group(1)
            elif (m := re.match(r"^Description\s+:\s+(.*)", line)) and current:
                out.setdefault(current, m.group(1))
    return out


def lines_of(path):
    return [l.strip() for l in path.read_text().splitlines() if l.strip() and not l.startswith("#")]


def main():
    files = ["pacman.txt", "hw-intel.txt", "hw-amd.txt", "laptop.txt"]
    groups = {}
    for f in files:
        for cat, name, note in parse(PKG / f):
            groups.setdefault(cat or f, []).append((name, note))
    all_names = [n for items in groups.values() for n, _ in items]
    desc = descriptions(all_names)

    md = [
        "# Packages",
        "",
        "Everything installed on the workstation, grouped by purpose.",
        "Generated from `packages/*.txt` by `scripts/gen-packages-md.py`; edit the `.txt` files, not this one.",
        "",
        f"**{len(all_names)} system packages** · hardware packages are chosen automatically at install time.",
        "",
        "## Contents",
        "",
    ]
    for cat in groups:
        anchor = re.sub(r"[^a-z0-9 -]", "", cat.lower()).replace(" ", "-")
        md.append(f"- [{cat}](#{anchor}) ({len(groups[cat])})")
    md.append("- [User-level tools](#user-level-tools)")
    md.append("")

    for cat, items in groups.items():
        md += [f"## {cat}", "", "| Package | What it is |", "|---|---|"]
        for name, note in items:
            text = desc.get(name, "")
            if note:
                text = f"{text} — *{note}*" if text else f"*{note}*"
            md.append(f"| `{name}` | {text.replace('|', '/')} |")
        md.append("")

    md += [
        "## User-level tools",
        "",
        "Installed per user by `install/user-setup.sh`, outside pacman.",
        "",
        "| Kind | Packages |",
        "|---|---|",
        f"| pip `--user` | {', '.join(f'`{p}`' for p in lines_of(PKG / 'pip.txt'))} |",
        f"| `uv tool` | {', '.join(f'`{p}`' for p in lines_of(PKG / 'uv-tools.txt'))} |",
        f"| VS Code extensions | {', '.join(f'`{p}`' for p in lines_of(PKG / 'vscode-extensions.txt'))} |",
        "| Rust | `rustup` stable toolchain |",
        "| Claude Code | official installer (`claude.ai/install.sh`) |",
        "",
    ]
    (REPO / "PACKAGES.md").write_text("\n".join(md))
    print(f"   wrote PACKAGES.md ({len(all_names)} packages)")


if __name__ == "__main__":
    main()
