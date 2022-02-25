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

# Script to install a Wordpress plugin from a git repo

install_git_plugin() {
   
    local LOCAL_GIT_REPO
    
    if [ ! -z $1 ]; then
        LOCAL_GIT_REPO=$1
    else
        echoerror "The function install_plugin_git() was called but not git_repo was sent.. please call the suporte to fix it!"
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Installing plugin from "$LOCAL_GIT_REPO
        echo 
    fi

    # Go to the Destination Folder
    cd $DESTINATION_FOLDER"/data/site/wp-content/plugins"

    # Update Permissions to Current User to Clone using keys if required
    sudo chown $USER"."$GROUP $DESTINATION_FOLDER"/data/site/wp-content/plugins"

    # Clone the repo to the plugin folder
    git clone $LOCAL_GIT_REPO

    if [ ! $? -eq 0 ]; then
        MESSAGE="Error trying to clone the repo "$LOCAL_GIT_REPO", please check the message above."
        return 1
    fi
    
    # Restore the Permissions to www-data
    sudo chown "www-data.www-data" $DESTINATION_FOLDER"/data/site/wp-content/plugins"

    cd - > /dev/null 2>&1
        
    return 0 
}

