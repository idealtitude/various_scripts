#!/usr/bin/env bash

app_version='0.1.0'
app_name='qtmp'
app_help="Usage: $app_name [EXT] [EDITOR] [OPTIONS]...

$app_name creates a temporary file, and delete it after use

Positional argument (optionals):
  EDITOR              Specify which editor to use to open the file (nano)
  EXT                 Extension of the file (default: txt)

Options:
         --del        Delete file after use
  v, -v, --version    Print app versiona and exit
  h, -h, --help       Print this help message and exit"

file_ext='txt'
default_editor='/usr/bin/nano'
delete_file=0

function del_file() {
    rm -rf "$1"
    printf "Deleted file: %s\n" "$1"
}

function make_temp_file() {
	tmp_file=$(mktemp --suffix ."$1")
	if [[ "$delete_file" -eq 1 ]]; then
	    trap "del_file $tmp_file" EXIT
	fi
	command "$default_editor" "$tmp_file"
	printf "Created file: %s\n" "$tmp_file"
	exit 0
}

if [[ "$#" -gt 0 ]]; then
	if [[ "$1" = "h" || "$1" = "-h" || "$1" = "--help" ]]; then
		printf "%s\n" "$app_help"
		exit 0
	elif [[ "$1" = "v" || "$1" = "-v" || "$1" = "--version" ]]; then
		printf "\033[94mVersion:\033[0m %s\n" "$app_version"
		exit 0
	else
        if [[ "$1" = "--del" || "$2" = "--del" || "$3" = "--del" ]]; then
            delete_file=1
        fi
		if [[ "$1" =~ ^[a-z0-9]+$ ]]; then
			if [[ "$#" -eq 2 && "$2" =~ ^[a-z0-9]+$ ]]; then
			    file_ext="$2"
			fi
			default_editor="$1"
			make_temp_file "$file_ext"
		fi
		printf "\033[101m[ERROR]\033[0m invalid argument %s; do %s -h\n" "$1" "app_name"
		exit 1
	fi
else
	make_temp_file "$file_ext"
fi
