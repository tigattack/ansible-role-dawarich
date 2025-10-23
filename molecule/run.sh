#!/usr/bin/env bash

set -e

role_symlink_dir='./tigattack.dawarich'

if [ ! -L "$role_symlink_dir" ]; then
  echo "Creating symlinked role directory for test: $role_symlink_dir"
  ln -s "$(pwd)" "$role_symlink_dir" > /dev/null
fi

pushd "$role_symlink_dir" > /dev/null

molecule "$@"

popd > /dev/null

rm "$role_symlink_dir"
