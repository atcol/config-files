{ config, lib, pkgs, ... }:
let 
  tmux-conf = builtins.readFile ./tmux.conf;
in
{
  programs.tmux = {
    enable = true;

    # Replaces ~/.tmux.conf
    extraConfig = tmux-conf;

  };
}
