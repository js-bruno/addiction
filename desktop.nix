{config, pkgs, ... }:
{
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
    systemPackages = with pkgs; [
        pavucontrol
        alttab

        pkgs.openobex
        pkgs.obexftp

        lxqt.pavucontrol-qt   
        lxqt.pcmanfm-qt       
        lxqt.qterminal        
        xarchiver   
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [ 
      elisa 
      konsole
      kate
    ];
  };

  services = {
    displayManager = {
      defaultSession = "plasmax11";
      gdm.enable = true;
    };
    desktopManager = {
      plasma6.enable = true;
    };
    xserver = {
      enable = true;
      desktopManager = {
        lxqt.enable = true;
        xterm.enable = true;
      };
      videoDrivers = [ "nvidia" ];
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          rofi
          feh
          i3status 
          i3lock 
          picom
          polybar
        ];
      };

      xkb = {
        layout = "us";
        variant = "";
      };
    };

    picom = {
      enable = false;
      vSync = true;
      backend= "glx";

      settings = {
        glx-no-stencil = true;
        glx-copy-from-front = false;
      };
    };
  };
}
