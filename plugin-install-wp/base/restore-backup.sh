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

# Script to restore backup file

restore_backup()
{

    if [ "$DEBUG" = true ]; then
        echo "Restoring backup file "$FILE_NAME" to "$DESTINATION_FOLDER
    fi

    cd $SOURCE_FOLDER
    tar -xzf $FILE_NAME --directory $DESTINATION_FOLDER
    cd - > /dev/null 2>&1
}

