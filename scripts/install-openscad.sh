#!/usr/bin/env bash
# Ensure an OpenSCAD CLI is available for STL export (Cloud Agent / CI).
# Prefers an existing install; otherwise installs the distro package (reliable).
# Optional: OPENSCAD_USE_NIGHTLY=1 to run scripts/install-openscad-nightly.sh instead.
set -euo pipefail

if [[ "${OPENSCAD_USE_NIGHTLY:-0}" == "1" ]]; then
  exec bash "$(cd "$(dirname "$0")" && pwd)/install-openscad-nightly.sh"
fi

if command -v openscad >/dev/null 2>&1; then
  echo "OpenSCAD already on PATH: $(command -v openscad)"
  openscad --version 2>&1 | head -1
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  echo "Installing OpenSCAD via apt…"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openscad
  openscad --version 2>&1 | head -1
  exit 0
fi

echo "error: no openscad on PATH and no apt-get available." >&2
echo "Install OpenSCAD locally, or set OPENSCAD_USE_NIGHTLY=1 for the AppImage helper." >&2
exit 1
