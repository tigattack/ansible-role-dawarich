#!/usr/bin/env bash

new_version=$(<min_dawarich_version.txt)

if command -v gsed >/dev/null 2>&1; then
  sedcmd='gsed'
else
  sedcmd='sed'
fi

$sedcmd -i -E "s/^(> \*\*Supported Dawarich version\(s\):\*\* [^0-9]+)([0-9]+\.[0-9]+(\.[0-9]+)?)/\1${new_version}/g" README.md

if `git diff --quiet README.md`; then
  echo "No changes made to README.md"
else
  echo "Updated supported Dawarich version to ${new_version} in README.md."
  git add README.md
fi
