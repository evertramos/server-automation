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

# Script to list all active plugins 

plugins_list_active()
{
    local LOCAL_COMPOSE_PATH

    goto_compose_folder

    LOCAL_COMPOSE_PATH=$COMPOSE_FOLDER_RESPONSE

    cd $LOCAL_COMPOSE_PATH
    PLUGINS_ACTIVE_LIST=$(docker-compose run --rm wpcli plugin list --status=active --field=name | tr -d '\r' | tr '\n' ' ')
    cd - > /dev/null 2>&1
}

