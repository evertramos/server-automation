
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

# Script to update the wp-config for the new site

update_wp_config()
{
    local LOCAL_WP_DEBUG LOCAL_WP_HOME LOCAL_WP_SITEURL LOCAL_STR_SUBSTITUTE LOCAL_WP_PATH LOCAL_NEW_URL LOCAL_UPDATE_URL

    if [[ ! -z $1 ]]; then
        LOCAL_UPDATE_URL=$1
    else
        LOCAL_UPDATE_URL=false
    fi

    if [[ ! -z $2 ]]; then
        LOCAL_NEW_URL=$2
    else
        LOCAL_NEW_URL=$DOMAIN
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Updating wp-config.php for "$LOCAL_NEW_URL" with debug = "$DEBUG
    fi

    if [[ "$WP_DEBUG" == true ]]; then
        LOCAL_WP_DEBUG="define( 'WP_DEBUG', true );"
    else 
        LOCAL_WP_DEBUG="define( 'WP_DEBUG', false );"
    fi
    
    if [[ "$LOCAL_UPDATE_URL" == true ]]; then
        LOCAL_WP_HOME="define( 'WP_HOME', 'http://"$LOCAL_NEW_URL"' );"
        LOCAL_WP_SITEURL="define( 'WP_SITEURL', 'http://"$LOCAL_NEW_URL"' );"
        LOCAL_STR_SUBSTITUTE="${LOCAL_WP_DEBUG}\n${LOCAL_WP_HOME}\n${LOCAL_WP_SITEURL}"
    else
        LOCAL_STR_SUBSTITUTE="${LOCAL_WP_DEBUG}"
    fi

    # We kept the $DOMAIN variable here because the folder still has the old name 
    # it will update after all files are ready in the clone script
    LOCAL_WP_PATH=$DESTINATION_FOLDER"/"$DOMAIN"/data/site/wordpress-core"

    cd $LOCAL_WP_PATH
    sed -i "/define( 'WP_DEBUG/c\\$LOCAL_STR_SUBSTITUTE" wp-config.php
    cd - > /dev/null 2>&1    
}

