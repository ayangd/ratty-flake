#!/usr/bin/env bash
set -euo pipefail

FLAKE="$(dirname "$(realpath "$0")")/flake.nix"
REPO="orhun/ratty"

echo "Fetching latest release..."
LATEST=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
VERSION="${LATEST#v}"

CURRENT=$(grep 'version = ' "$FLAKE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [[ "$VERSION" == "$CURRENT" ]]; then
  echo "Already at $VERSION."
  exit 0
fi

echo "Updating $CURRENT -> $VERSION"

# Prefetch new src hash
echo "Prefetching source..."
SRC_HASH=$(nix-prefetch-url --unpack "https://github.com/$REPO/archive/v${VERSION}.tar.gz" 2>/dev/null)
SRC_HASH_SRI=$(nix hash convert --hash-algo sha256 --to sri "$SRC_HASH")

# Update version
sed -i "s|version = \"$CURRENT\"|version = \"$VERSION\"|" "$FLAKE"

# Update rev
sed -i "s|rev = \"v$CURRENT\"|rev = \"v$VERSION\"|" "$FLAKE"

# Update src hash
OLD_SRC_HASH=$(grep -A4 'fetchFromGitHub' "$FLAKE" | grep 'hash = ' | sed 's/.*"\(.*\)".*/\1/')
sed -i "s|$OLD_SRC_HASH|$SRC_HASH_SRI|" "$FLAKE"

# Reset cargoHash to fakeHash so build reveals correct one
OLD_CARGO_HASH=$(grep 'cargoHash = ' "$FLAKE" | sed 's/.*"\(.*\)".*/\1/')
sed -i "s|cargoHash = \"$OLD_CARGO_HASH\"|cargoHash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\"|" "$FLAKE"

echo "Updated flake.nix to $VERSION"
echo "src hash: $SRC_HASH_SRI"
echo ""
echo "Next: nix build 2>&1 | grep 'got:' to get cargoHash, then update and rebuild."
