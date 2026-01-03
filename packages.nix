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
    claude-code
    gemini-cli
    awscli2
    nodejs
    zed-editor

    # JetBrains IDEs
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.rust-rover

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
