{
  description = "information_visualization_homework1";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        rpkgs = with inputs.nixpkgs.legacyPackages.${system}.rPackages; [
          DT
          ggplot2
          tidyverse
          showtext
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages =
            with pkgs;
            [
              R
              quarto
              noto-fonts-cjk-serif
            ]
            ++ rpkgs;
        };
      }
    );
}

