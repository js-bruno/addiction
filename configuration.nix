{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.interfaces.eth0.ipv4.addresses = [ { address = "192.168.1.99"; prefixLength = 24; } ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "8.8.8.8" ];
  networking.useDHCP = false;

  time.timeZone = "America/Fortaleza";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.flatpak.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
    nerd-fonts.comic-shanns-mono
  ];
  users.users.lacon = {
    isNormalUser = true;
    description = " jose bruno";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    flatpak
    lazygit
    git
    rofi
    stow
    zoxide
    librewolf
    vim
    alacritty
    tmux
    neovim
    wget
    dysk
    xclip

    ];
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim 
  #  wget
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "25.05";
}
