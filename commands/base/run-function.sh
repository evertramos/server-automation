# This file is part of a bigger script!
#
# Be careful when editing it

# ----------------------------------------------------------------------
#   
# Script devoloped to only Everet Ramos
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>     
#
# Copyright Evert Ramos with usage right granted to only Everet Ramos
#
# ----------------------------------------------------------------------

# Script to Call other functions in the script

# Function to check if the function itself exists and run it
run_function() {

    # Check $SILENT mode
    if [[ "$SILENT" == true ]]; then
        if [[ ! -z $3 ]]; then
            $1 "$2" "$3"
        elif [[ ! -z $2 ]]; then
            $1 "$2"
        else
            $1
        fi
    else
        echo "${yellow}[start]--------------------------------------------------${reset}"

        # Call the specified function
        if [[ -n "$(type -t "$1")" ]] && [[ "$(type -t "$1")" = function ]]; then
            echo "${cyan}...running function \"${1}\" to:${reset}"
            if [[ ! -z $3 ]]; then
                $1 "$2" "$3"
            elif [[ ! -z $2 ]]; then
                $1 "$2"
            else
                $1
            fi
        else
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>>[ERROR] Function \"$1\" not found!${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${yellow}[ended with ${red}[ERROR]${yellow}]-------------------------------------${reset}"
            exit 1
        fi

        # Show result from the function execution
        if [[ $? -ne 0 ]]; then
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> Ups! Something went wrong...${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> ${MESSAGE}${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${yellow}[ended with ${red}ERROR${yellow}/WARNING ($?)----------------------------${reset}"
            exit 1
        else
            echo "${green}>>> Success!${reset}"
        fi

        echo "${yellow}[end]----------------------------------------------------${reset}"
        echo
    fi
}

