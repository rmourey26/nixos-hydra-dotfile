{
   description = "Robert Mourey Jr's Nix system configuration";

   inputs = {
     nixpkgs.url = "nixpkgs/nixos-21.11";
     home-manager.url = "github:nix-community/home-manager";
     home-manager.inputs.nixpkgs.follows = "nixpkgs";
   };

   outputs = {self, nixpkgs, home-manager,...}:
   let
     system = "x86_64-linux";
     
     pkgs= import nixpkgs {
       inherit system;
       config = {allowUnfree = true; }; 
     };
    
     lib = nixpkgs.lib;

   in {
     nixosConfigurations = {
       nixos = lib.nixosSystem {
         inherit system;
    
         modules = [
            ./configuration.nix
         ];
      };
    };
  };
}
       
