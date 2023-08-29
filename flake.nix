{
  description = "RTPEngine - The Sipwise media proxy";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      overlay = self: super: { };
      pkgsForSystem = system: (import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
      });
    in
    {
      overlays.default = final: prev:
        let
          rtpengine = prev.callPackage ./rtpengine/default.nix { };
        in
        {
          inherit rtpengine;
        };
      packages = forAllSystems
        (system:
          let
            pkgs = pkgsForSystem system;
          in
          {
            rtpengine = pkgs.rtpengine;
            default = pkgs.rtpengine;
          });
      nixosModules.rtpengine = {
        imports = [ ./rtpengine/module.nix ];
        nixpkgs.overlays = [ self.overlays.default ];
      };
      nixosConfigurations.container = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.rtpengine
          ({ pkgs, config, ... }: {
            services.rtpengine.enable = true;
            services.rtpengine.settings = {
              interface = "any";
              table = -1;
              tos = 184;
              listen-ng = "127.0.0.1:22222";
              listen-http = "127.0.0.1:28222";
            };
            boot.isContainer = true;
#            boot.extraModulePackages = [ (config.boot.kernelPackages.callPackage ./rtpengine/kmod.nix { }) ];
#            boot.loader.grub.devices = [ "/dev/sda1" ];
#            fileSystems."/" = { device = "rpool/ROOT/nixos"; fsType = "zfs"; };
#            networking.hostId = "2495980a";
          })
        ];
      };
    };
}
