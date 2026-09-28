{self, inputs, ...}: {
  flake.nixosConfigurations.myDesktop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myDesktopConfiguration
    ];
  };
}
