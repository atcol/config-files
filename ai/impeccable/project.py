"""Install or remove optional project hooks using the globally managed skills."""

import argparse
import copy
import json
from pathlib import Path
import shlex
import shutil
import stat
import tempfile

MARKER = "# nix-impeccable\n"
ROOTS = {"claude": ".claude", "codex": ".agents", "gemini": ".gemini"}
SETTINGS = {
    "claude": ".claude/settings.json",
    "codex": ".codex/hooks.json",
    "gemini": ".gemini/settings.json",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("config", type=Path)
    parser.add_argument("--harness", choices=ROOTS, action="append")
    parser.add_argument("--remove", action="store_true")
    parser.add_argument("--project", type=Path, default=Path.cwd())
    args = parser.parse_args()
    config = json.loads(args.config.read_text())
    harnesses = args.harness or config["harnesses"]
    updates = []
    # Validate every file before changing any of them.
    for harness in dict.fromkeys(harnesses):
        if harness not in config["harnesses"] and not args.remove:
            parser.error(f"{harness} is not enabled in ai.impeccable.harnesses")
        path = args.project / SETTINGS[harness]
        if args.remove and not path.exists():
            continue
        if path.is_symlink():
            parser.error(f"Refusing to replace symlink: {path}")
        original = json.loads(path.read_text()) if path.exists() else {}
        updated = copy.deepcopy(original)
        hooks = updated.setdefault("hooks", {})
        for event, groups in list(hooks.items()):
            kept = []
            for group in groups:
                remaining = [hook for hook in group.get("hooks", [])
                             if not hook.get("command", "").startswith(MARKER)]
                if remaining or not group.get("hooks"):
                    kept.append({**group, "hooks": remaining} if "hooks" in group else group)
            if kept:
                hooks[event] = kept
            else:
                del hooks[event]
        if not args.remove:
            # Existing installer/plugin hooks are not ours to overwrite.
            if "skills/impeccable/scripts/impeccable" in json.dumps(hooks):
                parser.error(f"Existing unmanaged Impeccable hook in {path}; remove it first.")
            launcher = Path(config["home"]) / ROOTS[harness] / "skills/impeccable/scripts/impeccable"
            if not launcher.is_file():
                parser.error(f"Activate Home Manager first; missing {launcher}")
            incoming = json.loads((Path(config["bundle"]) / harness / "hooks.json").read_text())
            for event, groups in incoming.items():
                for group in groups:
                    for hook in group["hooks"]:
                        command = shlex.quote(str(launcher))
                        hook["command"] = MARKER + f"[ ! -x {command} ] || {command} hook"
                        hook.pop("commandWindows", None)
                hooks.setdefault(event, []).extend(groups)
        if not hooks:
            updated.pop("hooks")
        if updated != original:
            updates.append((path, updated))

    for path, content in updates:
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            backup = path.with_name(path.name + ".pre-impeccable")
            if not backup.exists():
                shutil.copy2(path, backup)
        with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            try:
                stream.write(json.dumps(content, indent=2) + "\n")
                stream.flush()
                if path.exists():
                    temporary.chmod(stat.S_IMODE(path.stat().st_mode))
                temporary.replace(path)
            finally:
                temporary.unlink(missing_ok=True)
        print(f"Updated {path}")
    if not args.remove:
        print("Hooks registered. Enable project checks with `impeccable hooks on` and complete any harness trust prompt.")


if __name__ == "__main__":
    main()
