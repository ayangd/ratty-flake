# ratty-flake

Nix flake for [Ratty](https://github.com/orhun/ratty) — a GPU-rendered terminal emulator with inline 3D graphics, built with Rust + Bevy.

## Heads up: your machine will go brrr

Ratty depends on **Bevy** (a full game engine) for GPU-rendered terminal graphics. This pulls in ~664 crates including wgpu, naga (shader compiler), winit, the entire async runtime, font/text shaping stacks, and platform windowing libraries. To make matters worse, two major versions of wgpu ship side-by-side (27 and 28) due to a version split between Bevy and Vello. Expect a long first build — release mode uses fat LTO with a single codegen unit across all of this.

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

The version and hashes live in `sources.json`, which `flake.nix` reads. The script will:
1. Query the GitHub API for the latest Ratty release tag
2. Prefetch the new source tarball and compute its hash
3. Update `version` and `srcHash` in `sources.json`
4. Build only the cargo vendor step to compute `cargoHash`, and write it to `sources.json`

If the vendor build fails for a reason other than a hash mismatch, the script prints the build log and exits, leaving a dummy `cargoHash` in `sources.json`.

After running the script, build:

```bash
nix build
```

If the build succeeds, commit the changes:

```bash
git add sources.json flake.lock && git commit -m "bump ratty to vX.Y.Z"
```

## Credits

Ratty is created by [Orhun Parmaksiz](https://github.com/orhun) — also the author of [Ratatui](https://github.com/ratatui/ratatui), [git-cliff](https://github.com/orhun/git-cliff), and many other great Rust tools. Check out [the blog post](https://blog.orhun.dev/introducing-ratty/) for the story behind Ratty.
