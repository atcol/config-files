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
# `grill-me` and `wayfinder` are the two user-invoked entry points; both are
# marked `disable-model-invocation` upstream, so they only ever run when you
# ask for them by name. The rest are the skills those two delegate to at
# runtime, and have to be installed for the entry points to work:
#
#   grill-me  -> grilling
#   wayfinder -> grilling, domain-modeling, research, prototype
#
# setup-matt-pocock-skills is not a dependency of either, but wayfinder's map
# reads a per-repo `docs/agents/issue-tracker.md` that only this skill knows
# how to scaffold, so it ships alongside them.
let
  upstream = ./ai/vendor/matt-pocock-skills/skills;
in
{
  # Entry points
  grill-me  = "${upstream}/productivity/grill-me";
  wayfinder = "${upstream}/engineering/wayfinder";

  # Delegated to at runtime by the entry points above
  grilling        = "${upstream}/productivity/grilling";
  domain-modeling = "${upstream}/engineering/domain-modeling";
  research        = "${upstream}/engineering/research";
  prototype       = "${upstream}/engineering/prototype";

  # Scaffolds the per-repo issue tracker / domain doc config wayfinder reads
  setup-matt-pocock-skills = "${upstream}/engineering/setup-matt-pocock-skills";
}
