#!/bin/bash

# Inspired by https://github.com/kou/arrow/blob/main/ci/scripts/util_free_space.sh

# This only cleans up the largest offender(s)
# If more space is needed, see link above

set -eu

echo "::group::Disk usage before cleanup"
df -h
echo "::endgroup::"

# Function for fast deletion using find
fast_delete() {
  local path="$1"
  if [ -d "$path" ]; then
    sudo find "$path" -type f -delete 2>/dev/null || :
    sudo find "$path" -depth -type d -delete 2>/dev/null || :
  fi
}

echo "::group::Clearing large directories"
declare -a large_dirs=(
  "/usr/local/lib/android"
  "/opt/hostedtoolcache/CodeQL"
  "/opt/hostedtoolcache/go"
  "microsoft/powershell"
)
for dir in "${large_dirs[@]}"; do
  [ -d "$dir" ] && echo "Removing $dir" && fast_delete "$dir"
done
echo "::endgroup::"

echo "::group::Clearing /usr/local"
declare -a locals_to_remove=(
  "julia*"
)
for local in "${locals_to_remove[@]}"; do
  echo "Removing /usr/local/$local"
  sudo rm -rf "/usr/local/$local" || :
done
echo "::endgroup::"

echo "::group::Disk usage after cleanup"
df -h
echo "::endgroup::"
