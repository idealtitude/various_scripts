#!/usr/bin/env bash

app_version='0.1.1'
app_name='junkify'
app_help="Usage: $app_name [NAME] [OPTIONS]...

$app_name create new junks...

Positional argument:
  NAME               The name of the new junk

Options:
  e, -e, --ext        Specify the extension of the file's new junk
  o, -o, --open       Open the file of the new junk in  an editor (default nano)
  E, -E, --editor     Specify which editor to use
  r, -r, --repl       Run interactively
  h, -h, --help       Print this help message and exit
  v, -v, --version    Print app version and exit"

qrepl_path="$HOME/bin/qrepl"
declare -a arguments=("$@")
junk_name=''
junk_path="$HOME/Dev/VAR/JUNK"
junk_ext='txt'
junk_open=0
junk_editor='nano'
junk_repl=0

function clean_exit() {
	popd || exit 1
	exit 0
}

function interactive() {
	pushd "$1" || exit 1
	trap clean_exit SIGINT SIGABRT
	if [[ "$4" -eq 1 ]]; then
	    command "$qrepl_path" -f "$2" -e "$3" -o
	else
	    command "$qrepl_path" -f "$2" -e "$3"
	fi
	popd || exit 1
}

function parse_args {
	local arg
	local next_key=0
	local current_key=0
	for key in "${!arguments[@]}"; do
		arg="${arguments[$key]}"
		case "$arg" in
			'h' | '-h' | '--help')
				printf "%s\n" "$app_help"
				exit 0
			;;
			'v' | '-v' | '--version')
				printf "\033[94mVersion:\033[0m %s\n" "$app_version"
				exit 0
			;;
			'e' | '-e' | '--ext')
				next_key="$current_key"
				((next_key++))
				junk_ext="${arguments[$next_key]}"
			;;
			'E' | '-E' | '--editor')
				next_key="$current_key"
				((next_key++))
				junk_editor="${arguments[$next_key]}"
			;;
			'o' | '-o' | '--open')
				junk_open=1
			;;
			'r' | '-r' | '--repl')
				junk_repl=1
			;;
			*)
				echo "" > /dev/null
			;;
		esac
		((current_key++))
	done
}

if [[ "$#" -eq 0 ]]; then
	printf "\033[91mError:\033[0m missing argument and/or option(s); do %s -h to display the help\n" "$app_name"
	exit 1
fi

junk_name="$1"
parse_args

new_junk_dir="$junk_path/$junk_name"

if [[ -d "$new_junk_dir" || -d "$junk_path/BAK/$junk_name" || -f "$new_junk_dir" || -f "$junk_path/BAK/$junk_name"  ]]; then
	printf "\033[93mWarning:\033[0m a junk with that name already exists\nChoose another name, or use 'q' to exit; "
	read -rp "name: " new_name
	if [[ "$new_name" = "q" ]]; then
		exit 0
	fi
	new_junk_dir="$junk_path/$new_name"
	junk_name="$new_name"
fi

new_junk_file="$junk_path/$junk_name/$junk_name.$junk_ext"

mkdir -p "$new_junk_dir"
touch "$new_junk_file"

if [[ "$junk_open" -eq 1 && "$junk_repl" -eq 0 ]]; then
    command "$junk_editor" "$new_junk_file"
    exit 0
fi

if [[ "$junk_repl" -eq 1 ]]; then
	interactive "$new_junk_dir" "$new_junk_file" "$junk_editor" "$junk_open"
fi

exit 0
