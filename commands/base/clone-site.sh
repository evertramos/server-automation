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

# Script to clone folder

clone_site()
{
    local LOCAL_SOURCE LOCAL_DESTINATION

    if [[ ! -z $1 ]]; then
        LOCAL_SOURCE=$1
    else
        LOCAL_SOURCE=$SOURCE_FOLDER
    fi

    if [[ ! -z $2 ]]; then
        LOCAL_DESTINATION=$2
    else
        LOCAL_DESTINATION=$DESTINATION_FOLDER
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Clone folder from: '$LOCAL_SOURCE' to '$LOCAL_DESTINATION'"
    fi

    mkdir -p $LOCAL_DESTINATION
    
    sudo cp -R $LOCAL_SOURCE"/compose" $LOCAL_DESTINATION
    sudo cp -R $LOCAL_SOURCE"/data" $LOCAL_DESTINATION

    # Update Permissions
    GROUP="$(id -g -n)"
    sudo chown $USER"."$GROUP -R $LOCAL_DESTINATION"/compose"
    sudo chown $USER"."$GROUP $LOCAL_DESTINATION"/data"
    sudo chown $USER"."$GROUP $LOCAL_DESTINATION"/data/site/wordpress-core"
    sudo chown $USER"."$GROUP -R $LOCAL_DESTINATION"/data/site/wordpress-core/wp-config.php"
    sudo chown "www-data.www-data" -R $LOCAL_DESTINATION"/data/site/wp-content"
}

