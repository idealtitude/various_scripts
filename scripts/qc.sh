#!/usr/bin/bash

tpl_path="$HOME/Dev/RES/tpl"
otpl=""
ncode=""

declare -a tpl_array

for t in "$tpl_path"/*; do
    tpl_name=$(basename "$t")
    tpl_array=(${tpl_array[@]} "$tpl_name")
done

function list_tpl {
    for t in "$tpl_path"/*; do
        local tpl_name
        tpl_name=$(basename "$t")
        printf "%s\n" "$tpl_name"
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

if [[ "$#" -eq 0 ]]
then
    printf "Usage: qc [TEMPLATE] [NAME]\n\nOptions:\n  [TEMPLATE]    The name of the template to use\n  [NAME]        The name of the folder to create\n"
    exit 0
elif [[ "$#" -eq 1 && "$1" = "-l" ]]
then
    list_tpl
    exit 0
fi

if [[ "$#" -ge 2 ]]
then
  checkVal "$1"
  if [[ "$?" -eq 1 ]]
  then
    otpl="$tpl_path/$1"
    ncode="$PWD/$2"

    printf "\033[1mCopying:\033[0m\n%s\n\033[1min\033[0m\n%s\n" "$otpl" "$ncode"

    if [[ -d "$ncode" ]]; then
        printf "\033[91mError:\033[0m a folder with this name already exists!\n"
        exit 1
    fi
    cp -r "$otpl" "$ncode"

    if [[ "$3" = "r" || "$3" = "-r" || "$3" = "--rename" ]]; then
        read -r -p "Rename main file: " newname

        if [[ -z "$newname" || "$newname" = "n" || "$newname" = "N" ]]; then
            printf "\033[32mDone!\033[0m\n"
            exit 0
        fi

        renm=$(rename_main "$ncode")
        mv "$renm" "$ncode/$newname"
    fi

    if [[ "$1" = "c" || "$1" = "cpp" ]]; then
        if [[ -f "$ncode/Makefile" ]]; then
    	    sed -i "s/{{out}}/$2/" "$ncode/Makefile"
    	fi
    fi

    if [[ "$1" = "pyuv" ]]; then
        mv "$ncode/src/proj" "$ncode/src/$2"
        mv "$ncode/src/$2/proj.py" "$ncode/src/$2/$2.py"
        mv "$ncode/data/proj.conf" "$ncode/data/$2.conf"
        sed -i "s/proj/$2/g" "$ncode/src/$2/$2.py"
        sed -i "s/proj/$2/g" "$ncode/.gitignore"
        sed -i "s/proj/$2/g" "$ncode/pyproject.toml"
        sed -i "s/proj/$2/g" "$ncode/README.md"
    fi

    printf "\033[32mDone!\033[0m\n"
    exit 0
  else
    printf "Error: template argument \"%s\" not found\n" "$1"
    exit 1
  fi
else
  echo "Wrong number of arguments... Do qc --help"
  exit 1
fi
