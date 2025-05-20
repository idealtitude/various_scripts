#!/usr/bin/env bash

tpl="$HOME/Dev/RES/tpl/c"
now=$(date +"%Y%m%d_%H%M%S")
dest="$HOME/Dev/VAR/QCODES/C/qcc_$now"

cp -r "$tpl" "$dest"

pushd "$dest" || exit 1

cp "$HOME/Dev/RES/EDITORCONFIG/.editorconfig" .

sed -i "s/{{out}}/qcc_$now/" "./Makefile"
xfce4-terminal -e "micro main.c" -T "qcc $now"

popd || exit 1

exit 0
