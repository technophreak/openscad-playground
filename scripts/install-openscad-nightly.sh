#!/usr/bin/env bash
# Install the latest official OpenSCAD Linux nightly (AppImage) for CLI use.
# Idempotent: safe to re-run from Cloud Agent environment install.
set -euo pipefail

INSTALL_DIR="${OPENSCAD_NIGHTLY_DIR:-/opt/openscad-nightly}"
BIN_LINK="${OPENSCAD_NIGHTLY_BIN:-/usr/local/bin/openscad-nightly}"
DEFAULT_LINK="${OPENSCAD_DEFAULT_BIN:-/usr/local/bin/openscad}"
SNAPSHOTS_JS="${OPENSCAD_SNAPSHOTS_JS:-https://files.openscad.org/snapshots/.snapshots.js}"
FALLBACK_URL="${OPENSCAD_NIGHTLY_URL:-}"

need_sudo() {
  if [[ -w "$(dirname "$1")" ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

resolve_url() {
  if [[ -n "${FALLBACK_URL}" ]]; then
    echo "${FALLBACK_URL}"
    return
  fi
  local js
  js="$(mktemp)"
  curl -fsSL --retry 3 "${SNAPSHOTS_JS}" -o "${js}"
  # Official metadata: setSnapshotFileInfo('LIN64_SNAPSHOT', name, size, url);
  python3 - "${js}" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(
    r"setSnapshotFileInfo\(\s*'LIN64_SNAPSHOT'\s*,\s*'[^']*'\s*,\s*'[^']*'\s*,\s*'(https://[^']+\.AppImage)'\s*\)",
    text,
)
if not m:
    sys.exit("error: could not find LIN64_SNAPSHOT AppImage URL in snapshots metadata")
print(m.group(1))
PY
  rm -f "${js}"
}

echo "Resolving latest OpenSCAD nightly AppImage…"
URL="$(resolve_url)"
echo "Downloading ${URL}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
appimage="${tmpdir}/OpenSCAD-nightly.AppImage"
curl -fL --retry 3 -o "${appimage}" "${URL}"
chmod +x "${appimage}"

need_sudo mkdir -p "${INSTALL_DIR}"
need_sudo rm -rf "${INSTALL_DIR}/squashfs-root"
(
  cd "${tmpdir}"
  ./OpenSCAD-nightly.AppImage --appimage-extract >/dev/null
)
need_sudo mv "${tmpdir}/squashfs-root" "${INSTALL_DIR}/squashfs-root"
need_sudo cp -f "${appimage}" "${INSTALL_DIR}/OpenSCAD-nightly.AppImage"
need_sudo chmod +x "${INSTALL_DIR}/OpenSCAD-nightly.AppImage"
need_sudo ln -sfn "${INSTALL_DIR}/squashfs-root/AppRun" "${BIN_LINK}"
# Prefer nightly over distro stable when /usr/local/bin is ahead of /usr/bin.
need_sudo ln -sfn "${BIN_LINK}" "${DEFAULT_LINK}"

echo "Installed OpenSCAD nightly:"
"${BIN_LINK}" --version
echo "CLI: ${BIN_LINK} (also linked as ${DEFAULT_LINK})"
