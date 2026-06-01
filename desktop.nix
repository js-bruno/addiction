{config, pkgs, ... }:
{
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    displayManager = {
      defaultSession = "gnome-xorg";
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
          polybar
      ];
    };
  };
}
