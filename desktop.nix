{config, pkgs, ... }:
{
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
    # XFCE PACKAGES ;e;
    systemPackages = with pkgs; [
        pavucontrol

        alttab
        xfce.xfce4-whiskermenu-plugin
        xfce.xfce4-docklike-plugin

        lxqt.pavucontrol-qt   
        lxqt.pcmanfm-qt       
        lxqt.qterminal        
        xarchiver   
    ];
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      displayManager = {
        defaultSession = "lxqt";
        gdm.enable = true;
      };
      desktopManager = {
        gnome.enable = true;
        xterm.enable = true;
        xfce.enable = true;
        lxqt.enable = true;
      };
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
      enable = true;
      vSync = true;
      backend= "glx";

      settings = {
        glx-no-stencil = true;
        glx-copy-from-front = false;
      };
    };
  };
}
