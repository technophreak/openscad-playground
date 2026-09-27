#!/usr/bin/env bash
# Render every parts/*.scad to stls/<name>.stl using the OpenSCAD CLI.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARTS_DIR="${ROOT}/parts"
OUT_DIR="${ROOT}/stls"
OPENSCAD="${OPENSCAD:-openscad}"

if ! command -v "${OPENSCAD}" >/dev/null 2>&1; then
  echo "error: '${OPENSCAD}' not found on PATH." >&2
  echo "Install OpenSCAD (any recent build is fine), then retry. See README.md." >&2
  exit 1
fi

echo "Using ${OPENSCAD} ($("${OPENSCAD}" --version 2>&1 | head -1))"

mkdir -p "${OUT_DIR}"

shopt -s nullglob
parts=("${PARTS_DIR}"/*.scad)
if [[ ${#parts[@]} -eq 0 ]]; then
  echo "error: no .scad files in ${PARTS_DIR}" >&2
  exit 1
fi

for scad in "${parts[@]}"; do
  name="$(basename "${scad}" .scad)"
  out="${OUT_DIR}/${name}.stl"
  echo "Rendering ${name}.scad → stls/${name}.stl"
  "${OPENSCAD}" -o "${out}" "${scad}"
done

echo "Done. STLs in ${OUT_DIR}"
