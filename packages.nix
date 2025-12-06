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
    rustfmt

    # General dev related tooling
    ollama
    gperftools
    wrk
    valgrind
    rust-analyzer
    git
    gitui
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
    qsv
    vscode
    claude-code
    awscli
    nodejs
    zed-editor

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
