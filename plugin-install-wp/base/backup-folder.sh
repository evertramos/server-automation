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

# Script to backup folder

backup_folder()
{
    local LOCAL_DATE_TIME LOCAL_BACKUP_FILE_NAME LOCAL_BACKUP_FOLDER LOCAL_DOMAIN_NAME

    if [ "$DEBUG" = true ]; then
        echo "Backing up folder $SOURCE_FOLDER to $DESTINATION_FOLDER."
    fi
   
    LOCAL_DATE_TIME=$(date "+%Y%m%d_%H%M%S")
    LOCAL_BACKUP_FOLDER=${DESTINATION_FOLDER%/}

    if [[ $DOMAIN == "" ]]; then
        LOCAL_BACKUP_FILE_NAME=$(basename $SOURCE_FOLDER | tr -dc '[:alnum:].' | tr '[:upper:]' '[:lower:]' | tr -d '[:cntrl:]')
        LOCAL_DOMAIN_NAME=$(basename $SOURCE_FOLDER)
    else
        LOCAL_BACKUP_FILE_NAME=$(echo $DOMAIN | tr -dc '[:alnum:].' | tr '[:upper:]' '[:lower:]' | tr -d '[:cntrl:]')
        LOCAL_DOMAIN_NAME=$DOMAIN
    fi

    BACKUP_FILE_NAME=$LOCAL_DATE_TIME"-"$LOCAL_BACKUP_FILE_NAME".tar.gz"

    cd $SITES_FOLDER 
    sudo tar -czf $LOCAL_BACKUP_FOLDER"/"$BACKUP_FILE_NAME $LOCAL_DOMAIN_NAME
    cd - > /dev/null 2>&1
}

