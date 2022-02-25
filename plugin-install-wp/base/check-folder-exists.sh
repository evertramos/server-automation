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

# Script to check if folder exists

check_folder_exists() 
{
    local LOCAL_FOLDER

    if [ ! -z $1 ]; then
        LOCAL_FOLDER=$1
    else
        echoerror "An error occurred when trying to check if folder exists [script: $SCRIPT_NAME - function: check_folder_exists]"
    fi
    
    if [ "$DEBUG" = true ]; then
        echo "Checking if folder $LOCAL_FOLDER exists."
    fi
    
    if [[ -d "$LOCAL_FOLDER" ]]; then
       FOLDER_EXIST=true
    else
       FOLDER_EXIST=false
    fi
    return 0
}

