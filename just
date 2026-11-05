#!/usr/bin/env sh
exec nix run nixpkgs#just -- "$@"
