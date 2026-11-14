#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <apk-file>" >&2
  exit 2
fi

artifact="$1"
if [[ ! -f "$artifact" || ! -s "$artifact" ]]; then
  echo 'APK artifact is missing or empty.' >&2
  exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
  echo 'SHA-256 verification requires sha256sum.' >&2
  exit 1
fi

artifact_dir="$(dirname -- "$artifact")"
artifact_name="$(basename -- "$artifact")"
checksum_name="${artifact_name}.sha256"
(
  cd -- "$artifact_dir"
  sha256sum -- "$artifact_name" > "$checksum_name"
  sha256sum --check "$checksum_name"
)
