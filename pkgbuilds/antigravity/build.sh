#!/bin/bash
set -euo pipefail

PKGNAME="antigravity"
VERSION="1.23.2"
TIMESTAMP="1776332190"
MD5="d29aa2e214aa69c5a7199fce43624422"
ARCH="x86_64"
CHECKSUM="bdd5f32d26791c36640bd2f713f5ebd6e78fe429c3cc27a72668fda6ad6317a4"

HOSTDIR="${1:?Usage: build.sh <hostdir>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEB_URL="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/pool/antigravity-debian/antigravity_${VERSION}-${TIMESTAMP}_amd64_${MD5}.deb"

STAGING=$(mktemp -d)
trap "rm -rf '$STAGING'" EXIT

echo "→ Downloading antigravity ${VERSION}…"
curl -fL "$DEB_URL" -o "$STAGING/antigravity.deb"
echo "$CHECKSUM  $STAGING/antigravity.deb" | sha256sum -c

(cd "$STAGING" && ar x antigravity.deb && tar xf data.tar.xz)

PKG="$STAGING/pkg"
mkdir -p "$PKG/opt/Antigravity"
cp -r "$STAGING/usr/share/antigravity/." "$PKG/opt/Antigravity/"

mkdir -p "$PKG/usr/local/bin"
install -m 755 "$SCRIPT_DIR/antigravity.sh" "$PKG/usr/local/bin/antigravity"

mkdir -p "$PKG/usr/share/applications" "$PKG/usr/share/pixmaps"
cp "$STAGING/usr/share/applications/antigravity.desktop" "$PKG/usr/share/applications/"
cp "$STAGING/usr/share/pixmaps/antigravity.png" "$PKG/usr/share/pixmaps/"

mkdir -p "$HOSTDIR"
(cd "$HOSTDIR" && xbps-create -q -A "$ARCH" \
  -n "${PKGNAME}-${VERSION}_1" \
  -s "Agentic development platform from Google" \
  --license "LicenseRef-Google-Antigravity" \
  --homepage "https://antigravity.google" \
  "$PKG")

xbps-rindex -a "$HOSTDIR"/*.xbps
sudo xbps-install --repository="$HOSTDIR" -y "$PKGNAME"
