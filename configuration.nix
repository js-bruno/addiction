{ config, pkgs, lib, ... }:
{ 
  imports = [ ./hardware-configuration.nix ./desktop.nix ];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "10G"; 

  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
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
      enable = false;
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
      printing.enable = true;
      pulseaudio.enable = false;
      resolved = {
        enable = true;
        extraConfig = ''
          DNSStubListener=no
          '';
      };
      flatpak.enable = true;
      # nginx = {
      #   enable = true;
      #   virtualHosts."blog.local" = {
      #     listen = [{ addr = "127.0.0.1"; port = 9000; }];
      #     root = "/home/lacon/projects/astro-project/dist";
      #   };
      # };

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
          extraGroups = [ "docker" "networkmanager" "wheel" "libvirtd"];
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
      # (pkgs-0_11.writeShellScriptBin "nvim-0_11" ''
      #     NVIM_APPNAME=nvim-0_11 exec ${pkgs-0_11.neovim}/bin/nvim "$@"
      #   '')
      #
      #   (pkgs-0_12.writeShellScriptBin "nvim-0_12" ''
      #     NVIM_APPNAME=nvim-0_12 exec ${pkgs-0_12.neovim}/bin/nvim "$@"
      #   '')

          flameshot
          mpv
          v4l-utils
          xclip
          unzip
          zip
          pavucontrol
          # nixd
          nil
          hyperfine

          android-tools
          dig
          ntfs3g
          zed-editor
          # vscode
          neovim
          gh
          docker-compose
          lazydocker
          hugo
          sqlite
          ncdu
          # ungoogled-chromium
          ripgrep
          zsh-autosuggestions
          git
          dysk
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
          # kando
          fzf
          sqlitebrowser
          prismlauncher
          lutris
          jstest-gtk
          p7zip
          heroic
          gamemode
          vulkan-tools
          protonup-qt 
          bottles 
          gearlever

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

    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 50;
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_end" = 80;
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
            # "portainer.homelab.local"
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

# let
  # # nixpkgs pinnado no commit do neovim 0.11.2
  # pkgs-0_11 = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz"; }) { inherit (pkgs) system; };
  
  # # nixpkgs-unstable atual (tem 0.12)
  # pkgs-0_12 = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
  # }) { inherit (pkgs) system; };

# in {
