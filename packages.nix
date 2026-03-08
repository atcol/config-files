{ config, lib, pkgs, ... }:
let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") {};

  kraken-cli = pkgs.rustPlatform.buildRustPackage rec {
    pname = "kraken-cli";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "krakenfx";
      repo = "kraken-cli";
      rev = "v${version}";
      hash = lib.fakeHash;
    };

    cargoHash = lib.fakeHash;

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ openssl ];

    meta = with lib; {
      description = "Kraken CLI";
      homepage = "https://github.com/krakenfx/kraken-cli";
      license = licenses.mit;
    };
  };
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
    gh
    codex
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
    kraken-cli
    awscli2
    nodejs
    #zed-editor

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
