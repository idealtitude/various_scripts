#!/usr/bin/env bash

app_version="0.2.1"
app_help="usage: qps [TEMPLATE] [PROJNAME] [OPTIONS]...

Options:
  p, -p, --project    Use the project template instead of the starter template
  v, -v, --version    Print app versiona and exit
  h, -h, --help       Print this help message and exit
  t, -t, --tpl        Print available template"

tpl="$HOME/Dev/RES/tpl"
cwd=$(pwd)
proj=""
tpls="c cpp bash py web"
tpl_suffix="starter"

if [[ "$#" -gt 1 && "$2" =~ ^-.+ ]]; then
	printf "\033[91mError:\033[0m project name can't start with a dash\n"
	exit 1
fi

if [[ "$#" -gt 2 ]]; then
    tpl_suffix="project"
fi

if [[ "$1" == "c" ]]; then
    proj="c_$tpl_suffix"
elif [[ "$1" == "cpp" ]]; then
    proj="cpp_$tpl_suffix"
elif [[ "$1" == "bash" ]]; then
    proj="bash_$tpl_suffix"
elif [[ "$1" == "py" ]]; then
    proj="py_$tpl_suffix"
elif [[ "$1" == "web" ]]; then
    proj="web_$tpl_suffix"
elif [[ "$1" = "v" || "$1" = "-v" || "$1" = "--version" ]]; then
	printf "\033[94mVersion:\033[0m %s\n" "$app_version"
	exit 0
elif [[ "$1" = "h" || "$1" = "-h" || "$1" = "--help" ]]; then
	printf "%s\n" "$app_help"
	exit 0
elif [[ "$1" = "t" || "$1" = "-t" || "$1" = "--tpl" ]]; then
	printf "Available templates: %s\n" "$tpls"
	exit 0
else
    printf "\033[91;1mError:\033[0m invalid argument \033[1m%s\033[0m, choose a template among %s\n" "$1" "$tpls"
    exit 1
fi

ftlp="$tpl/$proj"

if [[ ! -d "$ftlp" ]]; then
    printf "\033[91;1mError:\033[0m template not found at %s\n" "$ftlp"
    exit 1
fi

if [[ ! "$#" -gt 1 ]]; then
    printf "\033[91;1mError:\033[0m missing second argument, project name\n"
    exit 1
fi

cpy=$(cp -r "$ftlp" "$cwd/$2")

if [[ "$cpy" -eq 0 ]]; then
    printf "\033[92;1mSuccess!\033[0m %s has been copied to:\n%s\n" "$proj" "$cwd/$2"
    exit 0
fi

printf "\033[91;1mError:\033[0m failed to create new project:\n%s\n" "$cwd/$2"

exit 1
