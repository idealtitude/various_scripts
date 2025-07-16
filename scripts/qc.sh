#!/usr/bin/bash

app_version="0.3.2b"
help_message="Usage: qc [TEMPLATE] [NAME] [OPTIONS]...

Positional arguments:
  TEMPLATE           The name of the template to use
  NAME               The name of the folder to create

Options:
  s, -s, --select    Select template from a menu list
  l, -l, --list      List all available templates
  r, -r, --rename    Rename interactively the main file
  h, -h, --help      Print this help message and exit
  v, -v, --version   Print the current version and exit"

tpl_path="$HOME/Dev/RES/tpl"
otpl=""
ncode=""
lsttpl=$(ls "$tpl_path")
PS3="Select file: "
CWD="$PWD"

declare -a tpl_array

for t in "$tpl_path"/*; do
    tpl_name=$(basename "$t")
    tpl_array=(${tpl_array[@]} "$tpl_name")
done

function list_tpl {
    # for t in "$tpl_path"/*; do
        # local tpl_name
        # tpl_name=$(basename "$t")
        # printf "%s\n" "$tpl_name"
    # done
    eza "$tpl_path" | column -x
}

function menu_list {
    local item_name
    item_name=''
	select item in $lsttpl "Exit"; do
	    item_name="$item"
		if [[ "$item_name" = "Exit" ]]; then
			exit 0
		elif [[ -z "$item_name" ]]; then
		    printf "\033[1;91mError:\033[0m invalid choice\n"
		    exit 1
		else
            tpl="$tpl_path"/"$item_name"
			if [[ -d "$tpl" && "$tpl" != "$tpl_path" ]]; then
			    printf "Enter the name of the template folder copy, or hit enter to skip and use the default name (\"Unnamed\")\n"
			    read -rp "Name: " add_name
                changed_name="$add_name"
			    if [[ -z "$add_name" ]]; then
			        changed_name="Unnamed"
			    fi
				do_cpy=$(cp -ri "$tpl" "$CWD"/"$changed_name")
				if [[ "$do_cpy" -eq 0 ]]; then
					printf "\033[94mSuccess:\033[0m template copied to current working directory\n"
				fi
				exit 0
			else
				printf "\033[91mError:\033[0m the template folder has not been found\nExpected location: %s\n" "$tpl"
				exit 1
			fi
		fi
	done
}

function rename_main {
    chk=$(find "$1" -type f | grep 'main.*')
    printf "%s" "$chk"
}

checkVal () {
  for i in "${tpl_array[@]}"
  do
    if [ "$i" == "$1" ]
    then
        return 1
    fi
  done
  return 0
}

if [[ "$#" -eq 0 ]]; then
    printf "%s\n" "$help_message"
    exit 0
fi

if [[ "$#" -eq 1 ]]; then
    if [[ "$1" = "l" || "$1" = "-l" || "$1" = "--list" ]]; then
        list_tpl
        exit 0
    fi

    if [[ "$1" = "s" || "$1" = "-s" || "$1" = "--select" ]]; then
        menu_list
    fi

    if [[ "$1" = "h" || "$1" = "-h" || "$1" = "--help" ]]; then
        printf "%s\n" "$help_message"
        exit 0
    fi

    if [[ "$1" = "v" || "$1" = "-v" || "$1" = "--version" ]]; then
        printf "\033[1mqc\033[0m v\033[94m%s\033[0m\n" "$app_version"
        exit 0
    fi
fi

if [[ "$#" -ge 2 ]]; then
  checkVal "$1"
  if [[ "$?" -eq 1 ]]; then
    otpl="$tpl_path/$1"
    ncode="$PWD/$2"

    printf "\033[1mSRC:\t\033[0m %s\n\033[1mDEST:\033[0m\t%s\n" "$otpl" "$ncode"

    if [[ -d "$ncode" ]]; then
        printf "\033[91mError:\033[0m a folder with this name already exists!\n"
        exit 1
    fi
    cp -r "$otpl" "$ncode"

    if [[ "$3" = "r" || "$3" = "-r" || "$3" = "--rename" ]]; then
        read -r -p "Rename main file [.|nN]: " newname

        if [[ -z "$newname" || "$newname" = "n" || "$newname" = "N" ]]; then
            printf "\033[32mExit\033[0m\n"
            exit 0
        fi

        renm=$(rename_main "$ncode")
        mv "$renm" "$ncode/$newname"
    fi

    if [[ "$1" = "c" || "$1" = "cpp" || "$1" = "c_started" ]]; then
        sed -i "s/{{out}}/$2/" "$ncode/Makefile"
    elif [[ "$1" = "cmake_project" ]]; then
        sed -i "s/{{app}}/$2/" "$ncode/CMakeLists.txt"
        sed -i "s/{{app}}/$2/" "$ncode/README.md"
        sed -i "s/{{app}}/$2/" "$ncode/.gitignore"
    elif [[ "$1" = "cmake_min" ]]; then
        sed -i "s/{{app}}/$2/" "$ncode/CMakeLists.txt"
    elif [[ "$1" = "pyuv" ]]; then
        mv "$ncode/src/app" "$ncode/src/$2"
        mv "$ncode/src/$2/app.py" "$ncode/src/$2/$2.py"
        mv "$ncode/src/$2/data/app.conf" "$ncode/src/$2/data/$2.conf"
        sed -i "s/app/$2/g" "$ncode/src/$2/$2.py"
        sed -i "s/__program_name__/__app_name__/g" "$ncode/src/$2/$2.py"
        sed -i "s/app/$2/g" "$ncode/.gitignore"
        sed -i "s/app/$2/g" "$ncode/pyproject.toml"
        sed -i "s/app/$2/g" "$ncode/README.md"
    elif [[ "$1" = "clib" ]]; then
        mv "$ncode/src/libname.c" "$ncode/src/$2.c"
        mv "$ncode/include/libname.h" "$ncode/include/$2.h"
        sed -i "s/LIBNAME/$2/g" "$ncode/include/$2.h"
        sed -i 's/\( .*\)$/\U\1/g' "$ncode/include/$2.h"
        sed -i "s/libname/$2/g" "$ncode/src/$2.c"
        sed -i "s/libname/$2/g" "$ncode/tests/test.c"
        sed -i "s/libname/$2/g" "$ncode/README.md"
        sed -i "s/libname/$2/g" "$ncode/Makefile"
    elif [[ "$1" = "c_project" ]]; then
    	sed -i "s/app/$2/g" "$ncode/README.md"
    	sed -i "s/app/$2/g" "$ncode/Makefile"
    	sed -i "s/app/$2/g" "$ncode/doc/app.md"
    	mv "$ncode/doc/app.md" "$ncode/doc/$2.md"
    	sed -i "s/app/$2/g" "$ncode/src/main.c"
    	sed -i "s/app/$2/g" "$ncode/src/init.h"
    	sed -i "s/app/$2/g" "$ncode/.gitignore"
    elif [[ "$1" = "c_ncurses" ]]; then
    	sed -i "s/app/$2/g" "$ncode/Makefile"
    elif [[ "$1" = "node_starter" ]]; then
    	sed -i "s/app/$2/g" "$ncode/README.md"
    	sed -i "s/app/$2/g" "$ncode/.gitignore"
    elif [[ "$1" = "doc" ]]; then
        get_dnow=$(date +"%Y-%m-%d %H:%M:%S")
    	sed -i "s/documentation/$2/g" "$ncode/doc.md"
    	sed -i "s/Date:\*\*/Date:\*\* $get_dnow/" "$ncode/doc.md"
    	sed -i "s/documentation/$2/g" "$ncode/Makefile"
    	mv "$ncode/doc.md" "$ncode/$2.md"
    fi

    exit 0
  else
    printf "Error: template argument \"%s\" not found\n" "$1"
    exit 1
  fi
else
  echo "Wrong number of arguments... Do qc --help"
  exit 1
fi
