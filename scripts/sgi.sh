#!/usr/bin/env bash

app_version='0.0.1'
app_name='sgi'
app_help="Usage: $app_name [OPTIONS]...

$app_name is an app that allows uset o select a gitignore file from a list an copy it to current working directory

Options:
  v, -v, --version    Print app versiona and exit
  h, -h, --help       Print this help message and exit"

dirgi="$HOME/Dev/RES/GITIGNORES"
lstgi=$(ls "$dirgi")
PS3="Select file: "
CWD="$PWD"

function display_menu {
	select item in $lstgi "Exit"; do
		if [[ "$item" = "Exit" ]]; then
			exit 0
		else
			gi_path="$dirgi"/"$item"
			if [[ -f "$gi_path" ]]; then
				do_cpy=$(cp -i "$gi_path" "$CWD"/.gitignore)
				if [[ "$do_cpy" -eq 0 ]]; then
					printf "\033[94mSuccess:\033[0m gitignore copied to current working directory\n"
				fi
				exit 0
			else
				printf "\033[91mError:\033[0m the gitignore file has not been found\nExpected location: %s\n" "$gi_path"
				exit 1
			fi
		fi
	done
}

if [[ "$#" -gt 0 ]]; then
	if [[ "$1" = "h" || "$1" = "-h" || "$1" = "--help" ]]; then
		printf "%s\n" "$app_help"
		exit 0
	elif [[ "$1" = "v" || "$1" = "-v" || "$1" = "--version" ]]; then
		printf "\033[94mVersion:\033[0m %s\n" "$app_version"
		exit 0
	else
		gipath="$dirgi"/"$1".gitignore
		if [[ -f "$gipath" ]]; then
			docpy=$(cp -i "$gipath" "$CWD"/.gitignore)
			if [[ "$docpy" -eq 0 ]]; then
				printf "\033[94mSuccess:\033[0m gitignore copied to current working directory\n"
			fi
			exit 0
		else
			printf "\033[93mWarning:\033[0m file not found \"%s\"\n" "$gipath"
			exit 1
		fi
	fi
else
	display_menu
fi

exit 0
