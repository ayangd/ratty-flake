#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$(realpath "$0")")"
SOURCES="$DIR/sources.json"
REPO="orhun/ratty"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# Set a key in sources.json, writing through a temp file so a failure leaves no partial JSON
set_source() {
  local tmp
  tmp=$(mktemp "$SOURCES.XXXXXX")
  jq --arg key "$1" --arg value "$2" '.[$key] = $value' "$SOURCES" > "$tmp"
  mv "$tmp" "$SOURCES"
}

echo "Fetching latest release..."
LATEST=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
VERSION="${LATEST#v}"

CURRENT=$(jq -r .version "$SOURCES")

if [[ "$VERSION" == "$CURRENT" ]]; then
  echo "Already at $VERSION."
  exit 0
fi

echo "Updating $CURRENT -> $VERSION"

# Prefetch new src hash
echo "Prefetching source..."
SRC_HASH=$(nix-prefetch-url --unpack "https://github.com/$REPO/archive/v${VERSION}.tar.gz" 2>/dev/null)
SRC_HASH_SRI=$(nix hash convert --hash-algo sha256 --to sri "$SRC_HASH")

set_source version "$VERSION"
set_source srcHash "$SRC_HASH_SRI"

# Reset cargoHash to fakeHash so building the vendor step reveals the correct one
set_source cargoHash "$FAKE_HASH"

echo "Computing cargoHash..."
BUILD_LOG=$(nix build "$DIR#default.cargoDeps" --no-link 2>&1 || true)
CARGO_HASH=$(grep -oP 'got:\s+\Ksha256-\S+' <<< "$BUILD_LOG" || true)

if [[ -z "$CARGO_HASH" ]]; then
  echo "$BUILD_LOG"
  echo ""
  echo "Failed to compute cargoHash; sources.json still has the fake hash." >&2
  exit 1
fi

set_source cargoHash "$CARGO_HASH"

echo "Updated sources.json to $VERSION"
echo "src hash:   $SRC_HASH_SRI"
echo "cargo hash: $CARGO_HASH"
echo ""
echo "Next: nix build, then commit sources.json."
