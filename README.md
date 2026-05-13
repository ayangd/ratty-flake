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

## Updating to a new release

`update.sh` automates version bumps by fetching the latest release from GitHub:

```bash
./update.sh
```

This will:
1. Query the GitHub API for the latest Ratty release tag
2. Prefetch the new source tarball and compute its hash
3. Update `version`, `rev`, and `hash` in `flake.nix`
4. Reset `cargoHash` to a dummy value

After running the script, rebuild to get the correct cargo vendor hash:

```bash
nix build 2>&1 | grep 'got:'
```

Copy the `sha256-...` hash from the output, replace `cargoHash` in `flake.nix`, then build again:

```bash
nix build
```

If the build succeeds, commit the changes:

```bash
git add flake.nix flake.lock && git commit -m "bump ratty to vX.Y.Z"
```

## Credits

Ratty is created by [Orhun Parmaksiz](https://github.com/orhun) — also the author of [Ratatui](https://github.com/ratatui/ratatui), [git-cliff](https://github.com/orhun/git-cliff), and many other great Rust tools. Check out [the blog post](https://blog.orhun.dev/introducing-ratty/) for the story behind Ratty.
