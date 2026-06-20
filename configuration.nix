{ config, pkgs, lib, ... }:
{ 
  imports = [ ./hardware-configuration.nix ./desktop.nix ./minecraft_server.nix];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "10G"; 

  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs = {
    firefox.enable = true;
    zsh.enable = true;
    gamemode.enable = true;
    java.enable = true;
    thunar.enable  = true;
    xfconf.enable  = true;
    virt-manager.enable  = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          dns = [ "1.1.1.1" "8.8.8.8" ];
          registry-mirrors = [ "https://mirror.gcr.io" ];
        };
      };
    };
  };

  services = {
    udev.extraRules = ''
      KERNEL=="uinput", GROUP="uinput", MODE="0660"
      '';

    resolved = {
      enable = true;
      extraConfig = ''
        DNSStubListener=no
        '';
      fallbackDns = ["8.8.8.8" "8.8.4.4"];
    };

    input-remapper.enable = true;
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

  };

  users = {
    defaultUserShell=pkgs.zsh; 
    users= {
      lacon = {
        isNormalUser = true;
        description = " jose bruno";
        extraGroups = [ "input" "uinput" "docker" "networkmanager" "wheel" "libvirtd"];
        shell=pkgs.zsh;
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    sessionVariables = {
      SDL_GAMECONTROLLERCONFIG = "030000000c1200000e16000000000000,Generic PS3 Controller,platform:Linux,a:b2,b:b1,x:b3,y:b0,back:b8,start:b9,guide:b12,leftshoulder:b6,rightshoulder:b7,lefttrigger:a2,righttrigger:a5,leftx:a0,lefty:a1,rightx:a3,righty:a4,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftstick:b13,rightstick:b10,";
    };
    variables= {
      EDITOR = "/run/current-system/sw/bin/nvim";
    };
    shellAliases = {
      ll = "ls -l";
    };

    systemPackages = with pkgs; [
      joycond
      gparted
      flameshot
      mpv
      v4l-utils
      xclip
      unzip
      zip
      pavucontrol
      nixd
        # nil
      hyperfine

      android-tools
      dbeaver-bin
      dig
      ntfs3g

      zed-editor
      neovim
      gh
      docker-compose
      lazydocker
      hugo
      sqlite
      ncdu

      vivaldi
      ripgrep
      zsh-autosuggestions
      git
      dysk
      testdisk
      xclip
      librewolf
      curl
      stow
      zoxide
      caligula
      freshfetch
      qbittorrent
      vlc
      stremio
      plex
      visidata
      gnome-tweaks
      adw-gtk3
      colloid-gtk-theme
      yaru-theme
      gnome-boxes
      gnome-feeds
      newsflash
      alacritty
      ghostty
      wezterm
      kitty
      tmux

      fzf
      sqlitebrowser
      prismlauncher
      lutris
      jstest-gtk
      p7zip
      heroic
      vulkan-tools
      protonup-qt 
      bottles 
      gearlever

      bluetui
      btop
      fortune
      lazygit

      vim
      mongosh
      vi-mongo

      blanket

      golangci-lint
      gopls
      nodejs_24
      typescript-language-server
      vue-language-server
      gcc
      libgcc
      gnumake
      go
      lua
      lua-language-server

      spotify
      discord-ptb
      obsidian
      kdePackages.kdenlive

      qemu
      wine
      wine64
      winetricks

      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
      ];
  };

  fonts.packages = with pkgs; [
      monocraft
      nerd-fonts.blex-mono
      nerd-fonts.go-mono
      nerd-fonts.agave
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

  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 50;
    "net.ipv4.ip_unprivileged_port_end" = 80;
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.eth0.disable_ipv6" = 1;
  };
  boot.kernelModules = [ "uinput" ];
  security.rtkit.enable = true;
  networking = {
    hostName = "nixos"; 
    networkmanager.enable = true;
    interfaces.eth0.ipv4.addresses = [ { address = "192.168.1.99"; prefixLength = 24; } ];
    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1" "8.8.8.8" ];
    useDHCP = false;
    hosts = {
      "185.199.110.133" = ["raw.githubusercontent.com"];
      "127.0.0.1" = [
          "vikunja.homelab.local"
          "grafana.homelab.local"
          "uptime.homelab.local"
          "mealie.homelab.local"
          "vault.homelab.local"
          "homepage.homelab.local"
          "media.homelab.local"
          "zbruno.blog.com.br"
      ];
    };
  };
  time.timeZone = "America/Fortaleza";
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    supportedLocales = [
      "pt_BR.UTF-8/UTF-8"
        "ru_RU.UTF-8/UTF-8"
    ];
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
