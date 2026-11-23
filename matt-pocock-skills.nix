# Matt Pocock's skills, vendored as a pinned git submodule.
#
# Upstream: https://github.com/mattpocock/skills (MIT, (c) Matt Pocock)
# Checkout: ./ai/vendor/matt-pocock-skills
#
# Bump the pin with:
#   git submodule update --remote ai/vendor/matt-pocock-skills
#   git commit -am "chore: bump matt-pocock-skills"
#
# Clone this repo with --recurse-submodules, or run
# `git submodule update --init` in an existing checkout, before `home-manager
# switch` — the paths below are ordinary filesystem paths, so an uninitialised
# submodule fails evaluation with "path does not exist".
#
# User-invoked entry points and their runtime dependencies are shared by
# Claude Code, Codex, and Gemini CLI:
#
#   grill-me        -> grilling
#   grill-with-docs -> grilling, domain-modeling
#   retro           -> writing-for-agents
#   wayfinder       -> grilling, domain-modeling, research, prototype
#
# setup-matt-pocock-skills scaffolds the per-repo tracker and domain docs.
let
  upstream = ./ai/vendor/matt-pocock-skills/skills;
in
{
  # Entry points
  grill-me  = "${upstream}/productivity/grill-me";
  grill-with-docs = "${upstream}/engineering/grill-with-docs";
  retro = "${upstream}/engineering/retro";
  wayfinder = "${upstream}/engineering/wayfinder";

  # Delegated to at runtime by the entry points above
  writing-for-agents = "${upstream}/productivity/writing-for-agents";
  grilling        = "${upstream}/productivity/grilling";
  domain-modeling = "${upstream}/engineering/domain-modeling";
  research        = "${upstream}/engineering/research";
  prototype       = "${upstream}/engineering/prototype";

  # Scaffolds the per-repo issue tracker / domain doc config wayfinder reads
  setup-matt-pocock-skills = "${upstream}/engineering/setup-matt-pocock-skills";
}
