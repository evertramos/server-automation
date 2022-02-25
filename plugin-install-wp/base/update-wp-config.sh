
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
    local LOCAL_DOMAIN LOCAL_WP_DEBUG LOCAL_WP_HOME LOCAL_WP_SITEURL LOCAL_STR_SUBSTITUTE
    
    if [ ! -z $1 ]; then
        LOCAL_DOMAIN=$1
    else
        LOCAL_DOMAIN=$DOMAIN
    fi

    if [ "$DEBUG" = true ]; then
        echo "Updating wp-config.php for "$LOCAL_DOMAIN" with debug = "$DEBUG
    fi

    if [ "$WP_DEBUG" = true ]; then
        LOCAL_WP_DEBUG="define( 'WP_DEBUG', true );"
    else 
        LOCAL_WP_DEBUG="define( 'WP_DEBUG', false );"
    fi
    
    LOCAL_WP_HOME="define( 'WP_HOME', 'http://"$LOCAL_DOMAIN"' );"
    LOCAL_WP_SITEURL="define( 'WP_SITEURL', 'http://"$LOCAL_DOMAIN"' );"

    LOCAL_STR_SUBSTITUTE="${LOCAL_WP_DEBUG}\n${LOCAL_WP_HOME}\n${LOCAL_WP_SITEURL}"

    cd $DESTINATION_FOLDER"/data/site/wordpress-core"
    sed -i "/define( 'WP_DEBUG/c\\$LOCAL_STR_SUBSTITUTE" wp-config.php
    cd - > /dev/null 2>&1    
}

