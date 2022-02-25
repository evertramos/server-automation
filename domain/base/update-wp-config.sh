
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
    local LOCAL_WP_DEBUG LOCAL_WP_HOME LOCAL_WP_SITEURL LOCAL_STR_SUBSTITUTE

    if [ "$DEBUG" = true ]; then
        echo "Updating wp-config.php for "$DOMAIN
    fi
    
    LOCAL_WP_DEBUG="define( 'WP_DEBUG', "$WP_DEBUG" );"
    LOCAL_WP_HOME="define( 'WP_HOME', 'http://"$DOMAIN"' );"
    LOCAL_WP_SITEURL="define( 'WP_SITEURL', 'http://"$DOMAIN"' );"

    LOCAL_STR_SUBSTITUTE="${LOCAL_WP_DEBUG}\n${LOCAL_WP_HOME}\n${LOCAL_WP_SITEURL}"

    cd $DESTINATION_FOLDER"/data/site/wordpress-core"
    sed -i "/define( 'WP_DEBUG/c\\$LOCAL_STR_SUBSTITUTE" wp-config.php
    cd -
    
}

