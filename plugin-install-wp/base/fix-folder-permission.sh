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
    if [[ "$DEBUG" == true ]]; then
        echo "Setting the Wordpress folder ownership to 'www-data'"
    fi

    cd $DESTINATION_FOLDER"/data"
    sudo chown www-data.www-data -R site/
    cd - > /dev/null 2>&1
}
