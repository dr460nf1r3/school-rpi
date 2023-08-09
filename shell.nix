# Shell which contains all the tools needed to build the project
{ pkgs ?
  let
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/master.tar.gz";
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
    nativeBuildInputs = with pkgs; [
      binutils
    ];
  };
}
