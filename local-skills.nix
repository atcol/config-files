# Shared skills maintained under ./ai/skills or vendored under ./ai/vendor.
#
# Claude Code and Codex CLI install the same set, so it lives here rather than
# being written out twice — the two copies had already drifted (`cpp-cmake` and
# `worktrunk` were added to claude-code.nix only, while codex.nix still claimed
# its list was "same as Claude Code").
#
# Both tools copy these directories rather than symlinking them, because Claude
# can't read through a symlink to a skill's asset files.
#
# Matt Pocock's vendored skills are separate; see ./matt-pocock-skills.nix.
# Gemini CLI takes its own subset in ./custom-shell.nix, because each skill has
# to be flattened into a self-contained TOML command there.
{
  generate-smithy         = ./ai/skills/generate-smithy;
  api-to-proto            = ./ai/skills/api-to-proto;
  bootstrap-rust          = ./ai/skills/bootstrap-rust;
  cpp-cmake               = ./ai/skills/cpp-cmake;
  cpp-pro                 = ./ai/skills/cpp-pro;
  tdd                     = ./ai/skills/tdd;
  epic-decomposition      = ./ai/skills/epic-decomposition;
  adversarial-code-review = ./ai/skills/adversarial-code-review;
  adversarial-prd-review  = ./ai/skills/adversarial-prd-review;
  adversarial-rfc-review  = ./ai/skills/adversarial-rfc-review;
  worktrunk               = ./ai/skills/worktrunk;

  # Cloudflare's MIT-licensed skill, pinned as a git submodule.
  # Upstream: https://github.com/cloudflare/security-audit-skill
  # Initialise on a fresh checkout: git submodule update --init --recursive
  # Update: git submodule update --remote ai/vendor/security-audit-skill
  # Then commit ai/vendor/security-audit-skill to record the new pin.
  # The upstream LICENSE is retained at the submodule root.
  security-audit          = ./ai/vendor/security-audit-skill/skills/security-audit;

  thermo-nuclear-code-quality-review = ./ai/skills/thermo-nuclear-code-quality-review;
}
