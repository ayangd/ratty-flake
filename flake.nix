{
  description = "Nix flake for Ratty - GPU-rendered terminal emulator with inline 3D graphics";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "ratty";
        version = "0.2.0";

        src = pkgs.fetchFromGitHub {
          owner = "orhun";
          repo = "ratty";
          rev = "v0.2.0";
          hash = "sha256-fDNlyTOhwI1nzNf2/Z9DWtTEdJCZEDogLu13ETbpJAw=";
        };

        cargoHash = "sha256-4oLBONIyC924UGTw0d9RzGvNBolWdLMzzC+mihcD3B0=";

        nativeBuildInputs = with pkgs; [
          pkg-config
          cmake
          rustPlatform.bindgenHook
        ];

        buildInputs = with pkgs; [
          fontconfig
          wayland
          libxkbcommon
          vulkan-loader
          alsa-lib
          udev
          libx11
          libxcursor
          libxrandr
          libxi
        ];

        postFixup =
          let
            rpathLibs = pkgs.lib.makeLibraryPath (
              with pkgs;
              [
                vulkan-loader
                libxkbcommon
                wayland
              ]
            );
          in
          ''
            patchelf --add-rpath ${rpathLibs} $out/bin/ratty
          '';

        meta = with pkgs.lib; {
          description = "A GPU-rendered terminal emulator with inline 3D graphics";
          homepage = "https://github.com/orhun/ratty";
          license = licenses.mit;
          maintainers = [ ];
          platforms = [ "x86_64-linux" ];
          mainProgram = "ratty";
        };
      };
    };
}
