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

select_file() 
{
    if [ "$DEBUG" = true ]; then
        echo "There are multiple files with this domain. Now you will need to select which file you want to restore."
    fi
    
    cd $SOURCE_FOLDER
    FILES_OPTIONS=($(ls -p | grep -v / | tr '\n' ' '))
    cd - > /dev/null 2>&1

    echo "${blue}-----------------------------------------------------${reset}"
    echo 
    echo "${blue}Select one of the files you have in your backup folder:" 
    echo 
    
    # Call external function to select option
    select_option "${FILES_OPTIONS[@]}"
    FILE_INDEX=$?
    FILE_NAME=${FILES_OPTIONS[$FILE_INDEX]}
    echo "${blue}You have selected the file: "$FILE_NAME
    echo 
    echo "${blue}-----------------------------------------------------${reset}"
}
