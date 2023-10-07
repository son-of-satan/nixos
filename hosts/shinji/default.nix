{
  config,
  lib,
  pkgs,
  nixosModules,
  home-manager,
  disko,
  ...
} @ args: {
  imports = [
    home-manager.nixosModules.home-manager
    disko.nixosModules.disko
    nixosModules

    (import ./storage/primary-master.nix {
      device = {
        name = "sda";
        path = "/dev/disk/by-id/ata-KINGSTON_SA400S37480G_50026B7282CEDEB1";
      };
    })
  ];

  config = {
    networking.hostName = "shinji";

    modules.nixos.grub.enable = true;
    modules.nixos.networkmanager.enable = true;
    modules.nixos.pipewire.enable = true;
    modules.nixos.rtkit.enable = true;

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [config.boot.kernelPackages.rtl8821ce];

    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    boot.initrd.luks.devices.primary-rootvol.preLVM = lib.mkForce false;
    boot.initrd.luks.devices.primary-swapvol.preLVM = lib.mkForce false;
    boot.initrd.luks.devices.primary-homevol.preLVM = lib.mkForce false;

    fileSystems."/".device = lib.mkForce "/dev/disk/by-label/primary-root";
    fileSystems."/efi".device = lib.mkForce "/dev/disk/by-label/primary-efi";
    fileSystems."/boot".device = lib.mkForce "/dev/disk/by-label/primary-boot";
    fileSystems."/home".device = lib.mkForce "/dev/disk/by-label/primary-home";
  };
}