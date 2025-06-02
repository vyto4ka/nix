{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];
  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  # boot
  boot.loader.grub.enable                = true;
  boot.loader.grub.device                = "nodev";
  boot.loader.grub.useOSProber           = true;
  boot.loader.grub.efiSupport            = true;
  boot.loader.efi.canTouchEfiVariables   = true;
  boot.blacklistedKernelModules = [                 # fix ..... vbox
    "kvm_intel"
    "kvm"
  ];
  virtualisation.libvirtd.enable = false;

  # host
  networking.hostName                    = "vyt";
  # virtualisation.virtualbox.host.enable  = true;
  # users.extraGroups.vboxusers.members    = [ "vyto4ka" ];

  # networking
  networking.networkmanager.enable       = true;
  # services.openssh.enable                = true;

  # locales
  i18n.defaultLocale  = "ru_RU.UTF-8";
  time.timeZone       = "Europe/Moscow";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT    = "ru_RU.UTF-8";
    LC_MONETARY       = "ru_RU.UTF-8";
    LC_NAME           = "ru_RU.UTF-8";
  };

  # display manager 
  services.xserver = {
    enable = true;
    xkb = {
      layout  = "us,ru";
      variant = ",";
      options = "grp:alt_shift_toggle";
    };
  };

  services.displayManager.sddm = {
    enable       = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  # audio
  security.rtkit.enable      = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable      = true;
    pulse.enable = true;
    alsa.enable  = true;
  };

  # user
  users.users.vyto4ka = {
    isNormalUser = true;
    home         = "/home/vyto4ka";
    shell        = pkgs.fish;
    extraGroups  = [ "wheel" "networkmanager" ];
  };
  
  #some shit..
  environment.systemPackages = with pkgs; [
    freerdp
    fish
    fishPlugins.plugin-git
    fishPlugins.forgit
    nekoray
    qt5.qtbase
    qt5.qtsvg
    qt5.qtx11extras
    xorg.libX11
    xorg.libXext
    libglvnd
    gtk3
    xulrunner
    alsa-lib
  ];

  #fonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts."fira-code"
    nerd-fonts."jetbrains-mono"
    noto-fonts-emoji
  ];
  #for launching some apps
  programs.nix-ld.enable   = true;
  programs.nix-ld.package  = pkgs.nix-ld;
  programs.nix-ld.libraries = with pkgs; [
    glibc qt5.qtbase qt5.qtsvg qt5.qtx11extras xorg.libX11 xorg.libXext libglvnd gtk3 xulrunner alsa-lib
  ];
  
  #fish
  programs.fish = {
  enable = true;
  vendor = {
    config.enable     = true;
    completions.enable = true;
    functions.enable   = true;
  };
  interactiveShellInit = ''
    set -gx EDITOR nvim
  '';
};
  # home-manager
  home-manager.users.vyto4ka = import ./home.nix;
}
