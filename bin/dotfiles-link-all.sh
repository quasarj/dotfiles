#!/usr/bin/bash

echo Executing all dotfiles link scripts.
echo

for file in ~/.dotfiles/link-scripts/*.link; do
    $file
done
