#!/usr/bin/bash

echo Executing all dotfiles unlink scripts.
echo


for file in ~/.dotfiles/link-scripts/unlink*.sh; do
    $file
done
