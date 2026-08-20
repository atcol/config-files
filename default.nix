# `submodules = true` is load-bearing: ai/vendor/matt-pocock-skills is a git
# submodule, and fetchGit omits submodule content by default, which would make
# the skill paths in ./matt-pocock-skills.nix fail to evaluate.
(import (fetchTarball https://github.com/edolstra/flake-compat/archive/master.tar.gz) {
  src = builtins.fetchGit {
    url = ./.;
    submodules = true;
  };
}).defaultNix
