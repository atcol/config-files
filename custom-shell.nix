{ config, pkgs, ... }:
let
  shellAliases = {
    k = "kubectl";
    cat = "bat";
    we = "watchexec";
    find = "fd";
    cloc = "tokei";
    gpu = "git pull --rebase";
    gpus = "git push";
    gpusu = "git push --set-upstream origin ";
    gcom = "git commit ";
  };
in
{
  programs.git = {
    enable = true;
    userName  = "Alex";
    userEmail = "codeetc@pm.me";
  };

  programs.bash = {
    inherit shellAliases;
    enable = true;

    initExtra = ''
      eval "$(starship init bash)"
      set -o vi

    '';
  };
}
