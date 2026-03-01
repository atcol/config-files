{
  description = "My home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    peon-ping.url = "github:PeonPing/peon-ping";
    peon-ping.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system: {
      nixosModules.default = { ... }: { options = {}; config = import ./home.nix; };
    })
  ;
}
