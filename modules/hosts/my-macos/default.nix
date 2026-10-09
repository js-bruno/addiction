{self, inputs, ...}: {
  flake.nixosConfigurations.myMacOS = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myMacOSConfiguration
    ];
  };
}
