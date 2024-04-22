{ config, lib, pkgs, ... }:
let cfg = config.nuisance.modules.hm.tools.direnv;
in {
  options.nuisance.modules.hm.tools.direnv = {
    enable = lib.mkEnableOption "direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      config = pkgs.lib.importTOML ./direnv.toml;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
