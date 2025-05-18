#!/usr/bin/env bash

app_name="qac"
app_version="0.1.1"

declare -A colors
colors["black"]="\033[30m"
colors["red"]="\033[31m"
colors["green"]="\033[32m"
colors["yellow"]="\033[33m"
colors["blue"]="\033[34m"
colors["magenta"]="\033[35m"
colors["cyan"]="\033[36m"
colors["white"]="\033[37m"
colors["reset"]="\033[0m"

declare -A styles
styles["bold"]="\033[1m"
styles["dim"]="\033[2m"
styles["italic"]="\033[3m"
styles["uline"]="\033[4m"
styles["rev"]="\033[7m"
styles["hid"]="\033[8m"
styles["del"]="\033[9m"

print_help () {
	printf "Usage: %s [COLOR NAME]\n" "$app_name"
	printf "\n"
	printf "Options:\n"
	printf "  -a, --all        Display all the colors and styles, and exit\n"
	printf "  -C, --colors     Display all the colors and exit\n"
	printf "  -S, --styles     Display all the styles and exit\n"
	printf "  -c, --copy       Copy color code to clipboard\n"
	printf "  -h, --help       Print this help message and exit\n"
	printf "  -v, --version    Print app name + current version and exit\n"
	exit 0
}

print_version () {
	printf "%s %s\n" "$app_name" "$app_version"
	exit 1
}

print_color_code () {
	echo "${colors[$1]}"
}

check_color () {
	declare -i res=1
	for key in "${!colors[@]}"; do
		if [[ "$key" == "$1" ]]; then
			res=0
			break
		fi
	done

	echo "$res"
}

print_available_colors ()
{
    printf "\033[1mColors:\033[0m\n\n"
	for key in "${!colors[@]}"; do
		printf "%s" "${colors[$key]} "
		printf "%s → %b%s\033[0m\n" "$key" "${colors[$key]}" "$key"
	done
}

print_available_styles ()
{
    printf "\033[1mStyles:\033[0m\n\n"
    for key in "${!styles[@]}"; do
		printf "%s" "${styles[$key]} "
		printf "%s → %b%s\033[0m\n" "$key" "${styles[$key]}" "$key"
	done
}

print_available () {
    if [[ "$#" -eq 0 ]]; then
        print_available_colors
        printf "\n\n"
        print_available_styles
    else
        if [[ "$1" -eq 0 ]]; then
            print_available_colors
            printf "\n\n"
            print_available_styles
        elif [[ "$1" -eq 1 ]]; then
            print_available_colors
        elif [[ "$1" -eq 2 ]]; then
            print_available_styles
        else
            printf "\033[31mError:\033[0m invalid argument %d\n" "$1"
        fi
    fi
}

if [[ "$#" -eq 0 ]]; then
	print_help
fi

if [[ "$#" -eq 1 ]]; then
	arg="$1"

	if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
		print_help
	elif [[ "$arg" == "-v" ]] || [[ "$arg" == "--version" ]]; then
		print_version
	elif [[ "$arg" == "-a" ]] || [[ "$arg" == "--all" ]]; then
        print_available 0
	elif [[ "$arg" == "-C" ]] || [[ "$arg" == "--colors" ]]; then
        print_available 1
	elif [[ "$arg" == "-S" ]] || [[ "$arg" == "--styles" ]]; then
        print_available 2
	elif [[ "$arg" =~ [:lower:] ]] || [[ "$arg" == "cyan" ]]; then
		chk_color=$(check_color "$arg")

		if [[ "$chk_color" -eq 1 ]]; then
			printf "\033[31mError:\033[0m unknown color or option \033[1m%s\033[0m\n" "$arg"
			exit 1
		fi

		print_color_code "$arg"
		exit 0
	else
		printf "\033[31mError:\033[0m unknown or invalid argument \033[1m%s\033[0m\n" "$arg"
		exit 1
	fi
elif [[ "$#" -eq 2 ]]; then
	arg1="$1"
	arg2="$2"
	declare -i to_clipboard=0
	color="nil"
	if [[ "$arg1" == "-c" ]] || [[ "$arg1" == "--copy" ]]; then
		to_clipboard=1
		color="$arg2"
	elif [[ "$arg2" == "-c" ]] || [[ "$arg2" == "--copy" ]]; then
		to_clipboard=1
		color="$arg1"
	fi

	chk_color=$(check_color "$color")

	if [[ "$chk_color" -eq 1 ]]; then
		printf "\033[31mError:\033[0m unknown color \033[1m%s\033[0m\n" "$arg"
		exit 1
	fi

	if [[ "$to_clipboard" -eq 1 ]]; then

		printf "%s" "${colors[$color]}" | xsel -b -i > /dev/null
		printf "\033[32mSuccess!\033[0m Color \033[1m%s\033[0m copied to clipboard\n" "$color"
		exit 0
	fi

	print_color_code "$color"
fi
