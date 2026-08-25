# Skills authored in this repo, under ./ai/skills.
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
  tdd                     = ./ai/skills/tdd;
  epic-decomposition      = ./ai/skills/epic-decomposition;
  adversarial-code-review = ./ai/skills/adversarial-code-review;
  adversarial-prd-review  = ./ai/skills/adversarial-prd-review;
  adversarial-rfc-review  = ./ai/skills/adversarial-rfc-review;
  worktrunk               = ./ai/skills/worktrunk;

  thermo-nuclear-code-quality-review = ./ai/skills/thermo-nuclear-code-quality-review;
}
