{ config, lib, pkgs, ... }:
{
  home.packages = [
    # Rust related
    pkgs.cargo-watch
    pkgs.cargo-edit
    pkgs.cargo-tarpaulin
    pkgs.cargo-audit
    pkgs.cargo-outdated
    pkgs.cargo-release
    pkgs.cargo-udeps

    # Ocaml
    pkgs.ocamlPackages.ocaml-lsp

    # General dev related tooling
    pkgs.gperftools
    pkgs.wrk
    pkgs.valgrind
    pkgs.rust-analyzer
    pkgs.git
    pkgs.watchexec
    pkgs.ripgrep
    pkgs.tokei
    pkgs.bat
    pkgs.fd
    pkgs.xh
    pkgs.zenith
    pkgs.dhall
    pkgs.docker
    pkgs.docker-compose
    pkgs.terraform
    pkgs.jq
    pkgs.cue

    # Shell & environment
    pkgs.niv
    pkgs.starship
    pkgs.tmux
    pkgs.fzf
    pkgs.htop
    pkgs.terraform
    pkgs.kubectl
    pkgs.bat
  ];
}
