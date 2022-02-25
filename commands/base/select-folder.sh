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

# Script to list all backup files for this domain and let the user select 
# which file he wants to restore

select_folder() 
{
    local LOCAL_FOLDER LOCAL_MESSAGE

    if [[ ! -z $1 ]]; then
        LOCAL_FOLDER=$1
    else
        LOCAL_FOLDER=$SOURCE_FOLDER
    fi
    
    if [[ ! -z $2 ]]; then
        LOCAL_MESSAGE="$2"
    else
        LOCAL_MESSAGE="Select one of the SITES/FOLDERS below Clone:"
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Selecting the folder to continue."
    fi
    
    cd $LOCAL_FOLDER
    FOLDER_OPTIONS=($(ls -d */ | sed 's#/##'))
    cd - > /dev/null 2>&1

    echo "${blue}-----------------------------------------------------${reset}"
    echo 
    echo "${blue}$LOCAL_MESSAGE"
    echo 
    
    # Call external function to select option
    select_option "${FOLDER_OPTIONS[@]}"
    FOLDER_INDEX=$?
    FOLDER_NAME=${FOLDER_OPTIONS[$FOLDER_INDEX]}
    echo "${blue}You have selected the option: "$FOLDER_NAME
    echo 
    echo "${blue}-----------------------------------------------------${reset}"
}
