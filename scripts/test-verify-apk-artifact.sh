#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
verifier="$script_dir/verify-apk-artifact.sh"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

artifact="$tmp_dir/app-release.apk"
printf 'synthetic APK bytes\n' > "$artifact"
bash "$verifier" "$artifact" > "$tmp_dir/verification.log"

expected_digest="$(sha256sum "$artifact" | cut -d ' ' -f 1)"
recorded_digest="$(cut -d ' ' -f 1 "$artifact.sha256")"
[[ "$recorded_digest" == "$expected_digest" ]]
grep -Fq 'app-release.apk: OK' "$tmp_dir/verification.log"

download_dir="$tmp_dir/download"
mkdir "$download_dir"
cp "$artifact" "$artifact.sha256" "$download_dir/"
(cd "$download_dir" && sha256sum --check app-release.apk.sha256 >/dev/null)
printf 'tampered bytes\n' >> "$download_dir/app-release.apk"
if (cd "$download_dir" && sha256sum --check app-release.apk.sha256 >/dev/null 2>&1); then
  echo 'Tampered artifact unexpectedly passed checksum verification.' >&2
  exit 1
fi

if bash "$verifier" "$tmp_dir/missing.apk" > "$tmp_dir/missing.log" 2>&1; then
  echo 'Missing artifact unexpectedly passed verification.' >&2
  exit 1
fi
grep -Fq 'APK artifact is missing or empty.' "$tmp_dir/missing.log"

empty_artifact="$tmp_dir/empty.apk"
: > "$empty_artifact"
if bash "$verifier" "$empty_artifact" > "$tmp_dir/empty.log" 2>&1; then
  echo 'Empty artifact unexpectedly passed verification.' >&2
  exit 1
fi
grep -Fq 'APK artifact is missing or empty.' "$tmp_dir/empty.log"

echo 'APK artifact integrity tests passed.'
