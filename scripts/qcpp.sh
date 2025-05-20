#!/usr/bin/env bash

tpl="$HOME/Dev/RES/tpl/cpp"
now=$(date +"%Y%m%d_%H%M%S")
dest="$HOME/Dev/VAR/QCODES/CPP/qcpp_$now"

cp -r "$tpl" "$dest"

pushd "$dest" || exit 1

cp "$HOME/Dev/RES/EDITORCONFIG/.editorconfig" .

sed -i "s/{{out}}/qcpp_$now/" "./Makefile"
xfce4-terminal -e "micro main.cpp" -T "qcpp $now"

popd || exit 1

exit 0
