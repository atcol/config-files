"""Stage upstream's compiled provider bundles, replacing the downloading launcher."""

import pathlib
import shutil
import sys

source, output = map(pathlib.Path, sys.argv[1:3])
shell = sys.argv[3]
bundles = output / "share/impeccable"
for provider, directory in {"claude": ".claude", "codex": ".agents", "gemini": ".gemini"}.items():
    target = bundles / provider
    skill = target / "skills/impeccable"
    shutil.copytree(source / directory / "skills/impeccable", skill)
    agents = source / directory / "agents"
    if agents.exists():
        shutil.copytree(agents, target / "agents")

    # Global installs must not resolve scripts against the current project.
    # Keep relative Markdown references intact; only rewrite executable paths.
    for path in target.rglob("*"):
        if path.is_file() and path.suffix in {".md", ".toml", ".yaml", ".json"}:
            content = path.read_text()
            for prefix in (directory, ".codex" if provider == "codex" else directory):
                content = content.replace(f"{prefix}/skills/impeccable/scripts", str(skill / "scripts"))
            path.write_text(content)

    launcher = skill / "scripts/impeccable"
    launcher.write_text(
        f"#!{shell}\nset -eu\n"
        f"export IMPECCABLE_SKILL_DIR='{skill}'\n"
        'export IMPECCABLE_SELF="$0"\n'
        f'exec "{output}/libexec/impeccable" "$@"\n'
    )
    launcher.chmod(0o755)
    # Windows is not a target of this Home Manager package.
    (skill / "scripts/impeccable.cmd").unlink(missing_ok=True)

(output / "bin").mkdir()
(output / "bin/impeccable").symlink_to(bundles / "claude/skills/impeccable/scripts/impeccable")
shutil.copy2(source / "LICENSE", bundles / "LICENSE")
shutil.copy2(source / "NOTICE.md", bundles / "NOTICE.md")
