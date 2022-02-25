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

# Script to activate a Wordpress plugin from a git repo

activate_git_plugin() {
   
    local LOCAL_PLUGIN_NAME
    
    if [ ! -z $1 ]; then
        LOCAL_PLUGIN_NAME=${1##*/}
    else
        echoerror "The function install_plugin_git() was called but not git_repo was sent.. please call the suporte to fix it!"
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Activating plugin: "$LOCAL_PLUGIN_NAME
        echo 
    fi

    # Go to the Destination Folder
    cd ${DESTINATION_FOLDER%/}"/compose"

    # Activate the plugin
    docker-compose run --rm wpcli plugin activate $LOCAL_PLUGIN_NAME
    
    cd - > /dev/null 2>&1

    return 0 
}

