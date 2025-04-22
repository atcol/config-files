{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Rust related
    cargo
    cargo-watch
    cargo-edit
    cargo-tarpaulin
    cargo-audit
    cargo-outdated
    cargo-release
    cargo-udeps

    # General dev related tooling
    ollama
    rerun
    gperftools
    wrk
    valgrind
    rust-analyzer
    git
    watchexec
    ripgrep
    tokei
    bat
    fd
    xh
    zenith
    dhall
    docker
    docker-compose
    terraform
    jq
    cue
    direnv
    devenv
    jujutsu

    # Shell & environment
    niv
    starship
    tmux
    fzf
    htop
    terraform
    kubectl
    bat
  ];
}
