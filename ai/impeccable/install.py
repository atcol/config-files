"""Copy only owned Impeccable files; an empty manifest uninstalls them."""

import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile


def allowed(destination):
    return destination in {
        ".claude/skills/impeccable",
        ".agents/skills/impeccable",
        ".gemini/skills/impeccable",
        *(f".claude/agents/impeccable-{name}.md" for name in (
            "asset-producer", "documenter", "finish-reviewer", "manual-edit-applier"
        )),
    }


def remove(path):
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text())
    home = Path(manifest["home"])
    state = home / ".local/state/nix-impeccable/installed.json"
    previous = json.loads(state.read_text()) if state.exists() else []
    entries = {entry["destination"]: Path(entry["source"]) for entry in manifest["entries"]}
    for destination in set(previous) | entries.keys():
        if not allowed(destination):
            raise ValueError(f"Unexpected managed destination: {destination}")
    for destination, source in entries.items():
        path = home / destination
        if os.path.lexists(path) and destination not in previous:
            raise ValueError(f"Refusing to replace unmanaged {path}; move it aside before activation.")
        if not source.exists():
            raise ValueError(f"Missing Impeccable bundle: {source}")
    if args.check:
        return
    if not previous and not entries:
        return

    # Record ownership before copying, so an interrupted activation can retry.
    state.parent.mkdir(parents=True, exist_ok=True)
    pending = state.with_suffix(".tmp")
    pending.write_text(json.dumps(sorted(set(previous) | entries.keys())) + "\n")
    pending.replace(state)
    for destination, source in entries.items():
        target = home / destination
        target.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix=".impeccable-", dir=target.parent) as temporary:
            staged = Path(temporary) / "payload"
            if source.is_dir():
                shutil.copytree(source, staged)
            else:
                shutil.copy2(source, staged)
            for path in [staged, *staged.rglob("*")] if staged.is_dir() else [staged]:
                path.chmod(path.stat().st_mode | 0o200)
            remove(target)
            staged.replace(target)
    for destination in set(previous) - entries.keys():
        remove(home / destination)
    pending.write_text(json.dumps(sorted(entries)) + "\n")
    pending.replace(state)


if __name__ == "__main__":
    main()
