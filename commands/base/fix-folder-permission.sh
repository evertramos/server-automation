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

# Script to fix the folder permission

fix_folder_permission() 
{
    local LOCAL_DATA_PATH

    if [[ "$DEBUG" == true ]]; then
        echo "Setting the data folder ownership to www-data"
    fi
    
    check_folder_exists $WORKDIR"/data"

    if [[ $FOLDER_EXIST == false ]]; then
        check_folder_exists $WORKDIR"/"$DOMAIN"/data"

        if [[ $FOLDER_EXIST == false ]]; then
        
            check_folder_exists $WORKDIR"/"$NEW_URL"/data"

            if [[ $FOLDER_EXIST == false ]]; then
                echoerror "The docker-data.yml file was not found for '$DOMAIN' neither '$NEW_URL' at '$WORKDIR'"
            else
                LOCAL_DATA_PATH=$WORKDIR"/"$NEW_URL"/data"
            fi
        else
            LOCAL_DATA_PATH=$WORKDIR"/"$DOMAIN"/data"
        fi
    else
        LOCAL_DATA_PATH=$WORKDIR"/data"
    fi

    cd $LOCAL_DATA_PATH
    sudo chown www-data.www-data -R site/
    sudo chown 999.999 -R db/
    cd - > /dev/null 2>&1
}
