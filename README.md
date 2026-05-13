# ratty-flake

Nix flake for [Ratty](https://github.com/orhun/ratty) — a GPU-rendered terminal emulator with inline 3D graphics, built with Rust + Bevy.

## Usage

Add as a flake input:

```nix
{
  inputs.ratty = {
    url = "github:ayangd/ratty-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then use `inputs.ratty.packages.${system}.default` in your configuration.

## Build

```bash
nix build
./result/bin/ratty
```

## Update

```bash
./update.sh
nix build  # fails with correct cargoHash
# replace cargoHash in flake.nix
nix build  # succeeds
```
