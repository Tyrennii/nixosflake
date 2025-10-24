{
  description = "First NixOS flake with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Removed home-nix input since we're using local ./home.nix for consistency
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... } @inputs: {
    # Optional: Example package
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.hello;

    # Standalone Home Manager config (for non-NixOS activation if needed)
    homeConfigurations."arx" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };

    # Main NixOS configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # Passes inputs (e.g., hyprland) to modules
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          # Home Manager integration
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.arx = import ./home.nix;
          };
        }
      ];
    };
  };
}
