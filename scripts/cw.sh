#!/usr/bin/env bash

app_version="0.3.7"
app_name="cw"
app_help="Usage: $app_name [NUMBERS]... [OPTIONS]... [LOOPS] [N]

$app_name change wallpapers randomly, it can do it in a loop (see options below)

Options:
  [NUMBERS]...               Specifies which wallpaper folders to use, must be a number(s) between 1 and 11 (included)
  l, -l, --loop              Executes the command for [LOOPS] times
  k, -k, --kill              Kill the running loop if any
  i, -i, --interactive       Executes the command interactively
  d, -d, --delay             Sleeps for [N] seconds before changing wallpapers
  D, -D, --delay-loop        Sleeps for [N1] seconds and starts [N2] loops
  s, -s, --status            Status of the app (running or not,in case of loop)
  r, -r, --remaining-time    Displays the remaining time before next wallpaper change
  p, -p, --popup             Notifies when loop is finished
  c, -c, --clear             Clears the screen and enter interactive mode
  v, -v, --version           Prints app versiona and exit
  h, -h, --help              Prints this help message and exit
  q                          Exits interactive mode"

declare -a arguments=("$@")
declare -i dir1=0
declare -i dir2=0
declare -i notif=0

if [[ "$#" -gt 0 ]]; then
    for key in "${!arguments[@]}"; do
		arg="${arguments[$key]}"
		case "$arg" in
			'p' | '-p' | '--popup')
				notif=1
			;;
			# *)
				# printf "\033[91mError:\033[0m invalid argument and or option \033[1m%s\033[0m\n" "$arg"
				# exit 1
			# ;;
		esac
	done

fi

function do_change {
    local wp_folder="$HOME/Images/WALLPAPERS_00/"
    if [[ "$#" -eq 2 ]]; then
        dir1a="${wp_folder}WallPapers$1"
        dir2b="${wp_folder}WallPapers$2"
        #printf "dirs nums: %s\n" "$*"
        feh --no-fehbg --bg-max --randomize "$dir1a" "$dir2b"
    else
        feh --no-fehbg --recursive --bg-max --randomize "$wp_folder"
    fi
}

function remaining_time() {
    current_timestamp=$(date "+%s")
    timetogo=$(("$1" + 60))
    remain=$(("$timetogo - $current_timestamp"))
    echo "$remain"
}

function get_status {
    if [[ -f "$MYLOGS/chwpstatus.txt" ]]; then
        status_content=$(< "$MYLOGS/chwpstatus.txt")
        get_loop_id=$(echo "$status_content" | cut -d ' ' -f 1)
        previous_timestamp=$(echo "$status_content" | cut -d ' ' -f 2)
        remtime=$(remaining_time "$previous_timestamp")
        printf "\033[93mStatus:\033[0m a loop is runing; proc id is %d, remaining time: %s\n" "$get_loop_id" "$remtime"
    else
        printf "\033[95mStatus:\033[0m no loop is runing\n"
    fi
}

function progress_bar {
    local remt
    remt=$(get_status | rev | cut -d ' ' -f 1 | rev)
    local leading_zeros
    leading_zeros=''
    local trailing_dots
    trailing_dots=''
    local -i dot_counter
    dot_counter=0
    if [[ "$remt" =~ ^[0-9+$] ]]; then
        if [[ "$remt" -lt 3 ]]; then
            printf "Next change is just now...\n"
        else
            for (( i = "$remt"; i >= 0; i-- )); do
                if [[ "$i" -lt 10 ]]; then
                    leading_zeros='0'
                fi
                if [[ dot_counter -eq 1 ]]; then
                    trailing_dots='.  '
                elif [[ dot_counter -eq 2 ]]; then
                    trailing_dots='.. '
                elif [[ dot_counter -eq 3 ]]; then
                    trailing_dots='...'
                else
                    trailing_dots='   '
                fi
                ((dot_counter++))
                if [[ "$dot_counter" -eq 4 ]]; then
                    dot_counter=0
                fi
                printf "\rNext change in %s%d seconds (Ctrl+c to exit)%s" "$leading_zeros" "$i" "$trailing_dots"
                sleep 1
            done
            printf "\n"
        fi
    else
        printf "\033[93mStatus:\033[0m no loop is runing\n"
    fi
}

function kill_loop {
    if [[ -f "$MYLOGS/chwpstatus.txt" ]]; then
        get_loop_id=$(cut -d ' ' -f 1 < "$MYLOGS/chwpstatus.txt")
        if [[ ! "$get_loop_id" =~ ^[0-9]+$ ]]; then
            printf "\033[91mError:\033[0m process id doesn't seem valid; pid is %s\n" "$get_loop_id"
        else
            if [[ "$get_loop_id" -eq 0 ]]; then
                printf "\033[91mError:\033[0m process id is invalid; pid is %s\n" "$get_loop_id"
            fi
            do_kill=$(kill "$get_loop_id")
            if [[ "$do_kill" -eq 0 ]]; then
                rm "$MYLOGS/chwpstatus.txt"
                printf "Job %d successfully terminated!\n" "$get_loop_id"
            else
                printf "\033[91Error:\033[0m couldn't kill process %d\n" "$get_loop_id"
            fi
        fi
    else
        printf "\033[93mWarning:\033[0m there is no loop currently running\n"
    fi
}

function do_loop {
    if [[ ! -f "$MYLOGS/chwpstatus.txt" ]]; then
        touch "$MYLOGS/chwpstatus.txt"
    fi
    for (( i = 0 ; i < "$1" ; i++ )); do
        do_change
        tmpi=$(("$i" + 1))
        if [[ "$tmpi" -eq "$1" ]]; then
            rm "$MYLOGS/chwpstatus.txt"
            if [[ "$notif" -eq 1 ]]; then
                notify-send "$app_name finished"
            fi
            break
        else
            sleep 60
        fi
    done
}

function print_last_wp {
    # < "$MYLOGS/chwnohup.out" tail -n 1
    printf "\033[33mWarning:\033[0m this feature is not implemented yet\n"
}

function do_delay {
    sleep "$1"
    do_change
}

function delayed_loop {
    sleep "$1"
    do_loop "$2"
}

function interactive {
    while read -r -p "Change [Y|n]: " choice; do
        if [[ "$choice" =~ ^[0-9]+$ || "$choice" =~ ^[0-9]+\ [0-9]+$ ]]; then
            if [[ "$choice" =~ ^[0-9]+\ [0-9]+$ ]]; then
                dir1=$(echo "$choice" | cut -d ' ' -f1)
                dir2=$(echo "$choice" | cut -d ' ' -f2)
            else
                dir1="$choice"
                dir2="$choice"
            fi
            if [[ "dir1" -lt 1 || "$dir1" -gt 11 ]]; then
                printf "\033[33mWarning:\033[0m folder(s) number(s) must be greater than 0 and less than 12\n"
                dir1=0
                dir2=0
            else
                do_change "$dir1" "$dir2"
            fi
        elif [[ "$choice" = "n" || "$choice" = "q" ]]; then
            break
            exit 0
        elif [[ "$choice" = "Y" || "$choice" = "y" || -z "$choice" ]]; then
            # if [[ "$dir1" -gt 0 && $dir2 -gt 0 ]]; then
                # do_change "$dir1" "$dir2"
            # else
                # do_change
            # fi
            do_change
        elif [[ "$choice" = "s" || "$choice" = "-s" || "$choice" = "--status" ]]; then
            get_status
        elif [[ "$choice" = "r" || "$choice" = "-r" || "$choice" = "--remaining-time" ]]; then
            progress_bar
        elif [[ "$choice" = "p" || "$choice" = "-p" || "$choice" = "--print" ]]; then
            print_last_wp
        elif [[ "$choice" = "c" || "$choice" = "-c" || "$choice" = "--clear" ]]; then
            clear
        elif [[ "$choice" = "v" || "$choice" = "-v" || "$choice" = "--version" ]]; then
            printf "\033[94mVersion:\033[0m %s\n" "$app_version"
            exit 0
        elif [[ "$choice" = "h" || "$choice" = "-h" || "$choice" = "--help" ]]; then
            printf "%s\n" "$app_help"
            exit 0
        elif [[ "$choice" =~ ^l\ [0-9]+$ ]]; then
            lnb=$(echo "$choice" | sed -E 's/^.+\ ([0-9]+)/\1/')
            if [[ "$lnb" -lt 2 ]]; then
        		printf "\033[33mWarning:\033[0m number of loops must be greater than 1\n"
        	else
        		do_loop "$lnb" &
        		loopid="$!"
        		unix_timestamp=$(date "+%s")
        		printf "%d %d" "$loopid" > "$MYLOGS/chwpstatus.txt" "$unix_timestamp"
        	    exit 0
            fi
        else
            printf "\033[91mError:\033[0m unknown argument, \033[1m%s:\033[0m\n" "$choice"
        fi
    done
}

if [[ "$#" -gt 0 ]]; then
    num1=0
    num2=0
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        num1="$1"
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
            num2="$2"
        else
            num2="$1"
        fi
        if [[ "num1" -lt 1 || "num1" -gt 11 ]]; then
            printf "\033[33mWarning:\033[0m folder(s) number(s) must be greater than 0 and less than 12\n"
            exit 1
        fi
        #dir1="$num1"
        #dir2="$num2"
        do_change "$num1" "$num2"
        exit 0
    elif [[ "$1" = "h" || "$1" = "-h" || "$1" = "--help" ]]; then
        printf "%s\n" "$app_help"
        exit 0
    elif [[ "$1" = "v" || "$1" = "-v" || "$1" = "--version" ]]; then
        printf "\033[94mVersion:\033[0m %s\n" "$app_version"
        exit 0
    elif [[ "$1" = "s" || "$1" = "-s" || "$1" = "--status" ]]; then
        get_status
        exit 0
    elif [[ "$1" = "r" || "$1" = "-r" || "$1" = "--remaining-time" ]]; then
        progress_bar
        exit 0
    elif [[ "$1" = "p" || "$1" = "-p" || "$1" = "--print" ]]; then
        print_last_wp
        exit 0
    elif [[ "$1" = "l" || "$1" = "-l" || "$1" = "--loop" ]]; then
    	if [[ "$#" -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
    		if [[ "$2" -lt 2 ]]; then
				printf "\033[33mWarning:\033[0m number of loops must be greater than 1\n"
				exit 2
			else
				do_loop "$2" &
				loopid="$!"
				unix_timestamp=$(date "+%s")
				printf "%d %d" "$loopid" > "$MYLOGS/chwpstatus.txt" "$unix_timestamp"
				exit 0
			fi
		elif [[ "$#" -gt 1 && ! "$2" =~ ^[0-9]+$ ]]; then
			printf "\033[91mError:\033[0m second argument for the loop, \033[1m%s:\033[0m, is not a number\n" "$2"
			exit 1
		else
		    printf "\033[33mWarning:\033[0m no number of loops provided! Defaulting to ( loops)\n"
		    do_loop 5 &
		    loopid="$!"
		    unix_timestamp=$(date "+%s")
		    printf "%d %d" "$loopid" > "$MYLOGS/chwpstatus.txt" "$unix_timestamp"
    	fi
    elif [[ "$1" = "i" || "$1" = "-i" || "$1" = "--interactive" ]]; then
        interactive
        exit 0
    elif [[ "$1" = "d" || "$1" = "-d" || "$1" = "--delay" ]]; then
        delay_duration=5
        if [[ "$#" -gt 1 && "$2" =~ ^[0-9]+$ && "$2" -gt 2 && "$2" -lt 61  ]]; then
            delay_duration="$2"
        # else
            # printf "\033[33mWarning:\033[0m the value for the duration of the delay is missing or invalid (must be greater than 2 and less or equal to 60); defaulting to 5 seconds delay\n"
        fi
        do_delay "$delay_duration" &
        exit 0
    elif [[ "$1" = "D" || "$1" = "-D" || "$1" = "--delay-loop" ]]; then
        delay_dur=5
        loops_no=2
        if [[ "$#" -gt 1 && "$2" =~ ^[0-9]+$ && "$2" -gt 2 && "$2" -lt 61  ]]; then
            delay_dur="$2"
        fi
        if [[ "$#" -gt 2 && "$3" =~ ^[0-9]+$ && "$3" -gt 1 && "$3" -lt 10  ]]; then
            loops_no="$3"
        fi
        delayed_loop "$delay_dur" "$loops_no" &
        loopid="$!"
		unix_timestamp=$(date "+%s")
		printf "%d %d" "$loopid" > "$MYLOGS/chwpstatus.txt" "$unix_timestamp"
        exit 0
    elif [[ "$1" = "k" || "$1" = "-k" || "$1" = "--kill" ]]; then
        kill_loop
        exit 0
    elif [[ "$1" = "c" || "$1" = "-c" || "$1" = "--clear" ]]; then
        clear
        read -n 1 -r -p "Go to interactive mode [Y|n]: " gotointer
        if [[ "$gotointer" = "Y" || "$gotointer" = "y" || -z "$gotointer" ]]; then
            printf "\n"
            interactive
        else
            do_change
            exit 0
        fi
    else
    	printf "\033[91mError:\033[0m unknown argument(s) or option(s) \033[1m%s:\033[0m\n" "$*"
    	exit 1
    fi
else
	do_change
fi

exit 0
