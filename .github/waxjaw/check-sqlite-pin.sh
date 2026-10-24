#!/bin/sh
# Fails if the vendored SQLite amalgamation or the CSQLite compile flags drift
# from the pinned SQLite 3.54.1 release (sqlite-amalgamation-3540100.zip,
# sha3-256 92281c86e2957f9b9305890f9ac04204caa7b677cc868dc326d942689df28e30).
# Update the pins only together with a reviewed amalgamation or flag change.
set -eu
cd "$(dirname "$0")/../.."
shasum -a 256 -c .github/waxjaw/sqlite-pin.sha256
actual=$(mktemp)
awk '/name: "CSQLite"/{f=1} f&&/\.define\(/{gsub(/^[ \t]+/,""); print} f&&/^            \]/{exit}' Package.swift > "$actual"
if ! diff -u .github/waxjaw/csqlite-defines.txt "$actual"; then
  echo "CSQLite cSettings drifted from .github/waxjaw/csqlite-defines.txt" >&2
  exit 1
fi
grep -q '^#define SQLITE_VERSION  *"3\.54\.1"' Sources/CSQLite/include/sqlite3.h
echo "SQLite pin verified"
