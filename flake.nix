{
  description = "First NixOS flake";


programs.hyprland.enable = true;


  
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";  # Changed to master
      inputs.nixpkgs.follows = "nixpkgs";
    };
  hyprland = {
    url = "github:hyprwm/Hyprland";
    inputs.nixpkgs.follows = "nixpkgs";
  };

    home-nix = {
      url = "path:/home/arx/.config/home-manager";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, home-nix, hyprland, ... } @inputs: {
    packages.x86_64-linux = {
      hello = nixpkgs.legacyPackages.x86_64-linux.hello;
      default = self.packages.x86_64-linux.hello;
      nixosConfiguration.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; #important part apparently
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.arx = import ./home.nix;

            programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
            };
            };
   ];     
};
     };
    };

    homeConfigurations."arx" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        "${inputs.home-nix}/home.nix"
      ];
    };

    nixosConfigurations.myNixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos/configuration.nix
      ];
    };
  };
}
