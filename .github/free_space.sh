#!/bin/bash

# Inspired by https://github.com/kou/arrow/blob/main/ci/scripts/util_free_space.sh

set -eu

echo "::group::Disk usage before cleanup"
df -h
echo "::endgroup::"

# Function for parallel deletion
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
)
for dir in "${large_dirs[@]}"; do
  echo "Removing $dir"
  fast_delete "$dir"
done
echo "::endgroup::"

echo "::group::Clearing /usr/local"
declare -a locals_to_remove=(
  "aws-sam-cli"
  "julia*"
)
for local in "${locals_to_remove[@]}"; do
  echo "Removing /usr/local/$local"
  sudo rm -rf "/usr/local/$local" || :
done
echo "::endgroup::"

echo "::group::Clearing /usr/local/bin"
declare -a bins_to_remove=(
  "aliyun"
  "azcopy"
  "bicep"
  "cmake-gui"
  "cpack"
  "helm"
  "hub"
  "kubectl"
  "minikube"
  "node"
  "packer"
  "pulumi*"
  "sam"
  "stack"
  "terraform"
  "oc"
)
for bin in "${bins_to_remove[@]}"; do
  echo "Removing /usr/local/bin/$bin"
  sudo rm -f /usr/local/bin/$bin || :
done
echo "::endgroup::"

echo "::group::Clearing /usr/local/share"
declare -a shares_to_remove=(
  "chromium"
  "powershell"
)
for share in "${shares_to_remove[@]}"; do
  echo "Removing /usr/local/share/$share"
  sudo rm -rf "/usr/local/share/$share" || :
done
echo "::endgroup::"

echo "::group::Clearing /usr/local/lib"
declare -a libs_to_remove=(
  "heroku"
  "node_modules"
)
for lib in "${libs_to_remove[@]}"; do
  echo "Removing /usr/local/lib/$lib"
  sudo rm -rf "/usr/local/lib/$lib" || :
done
echo "::endgroup::"

echo "::group::Clearing /opt"
declare -a opts_to_remove=(
  "az"
  "microsoft/powershell"
)
for opt in "${opts_to_remove[@]}"; do
  echo "Removing /opt/$opt"
  sudo rm -rf "/opt/$opt" || :
done
echo "::endgroup::"

echo "::group::Clearing /opt/hostedtoolcache"
declare -a toolcaches_to_remove=(
  "CodeQL"
  "go"
  "PyPy"
  "node"
)
for toolcache in "${toolcaches_to_remove[@]}"; do
  echo "Removing /opt/hostedtoolcache/$toolcache"
  sudo rm -rf "/opt/hostedtoolcache/$toolcache" || :
done
echo "::endgroup::"

echo "::group::Clearing browser installations"
browsers_to_remove=(
  "firefox"
  "google-chrome-stable"
  "microsoft-edge-stable"
)
echo "Removing browsers: ${browsers_to_remove[*]}"
sudo apt purge -y -qq "${browsers_to_remove[@]}" || :
echo "::endgroup::"

echo "::group::Disk usage after cleanup"
df -h
echo "::endgroup::"
