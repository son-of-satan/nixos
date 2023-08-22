{ config, pkgs, ... }:
{
  config = {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      gfxmode = "auto";
    };
  };
}
