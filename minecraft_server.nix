{pkgs, lib, ...}:
{
  services.minecraft-server = {
    package = pkgs.papermc;
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;
    jvmOpts = "-Xms2048M -Xmx2048M"; 
    
    serverProperties = {
      online-mode = false;
      server-port = 43000;
      difficulty = 3;
      gamemode = 0;
      max-players = 5;
      motd = "NixOS Minecraft server!";
      white-list = false;
      enable-rcon = true;
      "rcon.password" = "hunter2";
    };
    # whitelist = {
    #   username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    #   username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
    # };
  };
}
