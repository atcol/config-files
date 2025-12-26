{ config, lib, pkgs, ... }:
let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") {};
in 
{
  home.packages = with pkgs; [
    # Rust related
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "rust-analyzer"
    ])

    # General dev related tooling
    ollama
    gperftools
    wrk
    valgrind
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
    awscli2
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
