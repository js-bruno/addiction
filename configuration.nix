{ config, pkgs, ... }:

{
  imports =
    [ 
    ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs = {
    firefox.enable = true;
    zsh.enable = true;
    gamemode.enable = true;
    java.enable = true;
    thunar.enable  = true;
    xfconf.enable  = true;
    virt-manager.enable  = true;
  };

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  services = {
    printing.enable = true;
    pulseaudio.enable = false;
    flatpak.enable = true;

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      displayManager = {
        defaultSession = "xterm+i3";
        gdm.enable = true;
      };
      desktopManager = {
        gnome.enable = true;
        xterm.enable = true;
      };
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
            rofi
            feh
            i3status 
            i3lock 
            picom
        ];
      };
    };
  };

  users = {
    defaultUserShell=pkgs.zsh; 
    users= {
      lacon = {
        isNormalUser = true;
        description = " jose bruno";
        extraGroups = [ "networkmanager" "wheel" "libvirtd"];
        shell=pkgs.zsh;
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    shellAliases = {
      ll = "ls -l";
    };

    systemPackages = with pkgs; [
        nixd
        hyperfine
        gopls

        hugo
        nodejs_24

        qemu
        libgcc
        ripgrep
        zsh-autosuggestions
        git
        dysk
        xclip
        vivaldi
        librewolf
        curl
        stow
        zoxide
        obsidian
        qbittorrent
        vlc
        plex
        jellyfin
        jellyfin-web
        jellyfin-ffmpeg
        visidata

        alacritty
        ghostty
        wezterm
        kitty
        tmux

        mangohud 
        prismlauncher
        lutris
        protonup-qt 
        bottles 
        gearlever

        btop
        fortune
        lazygit

        go
        vim
        neovim
        lua-language-server

        ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.go-mono
      nerd-fonts.iosevka-term
      nerd-fonts.daddy-time-mono
      nerd-fonts.envy-code-r
      nerd-fonts.comic-shanns-mono
      nerd-fonts.shure-tech-mono
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  security.rtkit.enable = true;
  networking = {
    hostName = "nixos"; 
    networkmanager.enable = true;
    interfaces.eth0.ipv4.addresses = [ { address = "192.168.1.99"; prefixLength = 24; } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" ];
    useDHCP = false;
  };
  time.timeZone = "America/Fortaleza";
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings = {
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
  };
  system.stateVersion = "25.05";
}
