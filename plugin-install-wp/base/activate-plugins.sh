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

# Script to activate the Wordpress plugins from the list in a file

activate_plugins() {
   
    local LOCAL_FILE_FULLPATH LOCAL_FILE_NAME LOCAL_PLUGIN_NAME
    
    if [ ! -z $1 ]; then
        LOCAL_FILE_NAME=$1
    else
        LOCAL_FILE_NAME=$FILE_NAME
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Installing plugins list from "$LOCAL_FILE_NAME
        echo 
    fi

    # Get Fullpath filename
    LOCAL_FILE_FULLPATH=$SOURCE_FOLDER"/"$LOCAL_FILE_NAME

    # Go to the Destination Folder
    cd ${DESTINATION_FOLDER%/}"/compose"

    # Loop through each line of the file
    while read -r line
    do
        if [[ "$DEBUG" == true ]]; then
            echo "${blue}>>> Activating plugin: $line ${reset}"
        fi
        LOCAL_PLUGIN_NAME=$line

        # Need to change the stdin in order to run other lines ("< /dev/null" at the end)
        docker-compose run --rm wpcli plugin activate $LOCAL_PLUGIN_NAME < /dev/null
        
        if [[ "$DEBUG" == true ]]; then
            echo "${blue}<<< end ["$line"]${reset}"
            echo
        fi
    done < $LOCAL_FILE_FULLPATH

    cd - > /dev/null 2>&1

    return 0 
}

