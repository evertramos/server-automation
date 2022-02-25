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

# Script to load all functions in base script folder

# Set Local Folder Name
LOCAL_FOLDER=base

# Get Current directory
LOCAL_PATH="$(dirname "$(readlink -f "$0")" )"

# Bootstrap file name
BOOTSTRAP_FILE_NAME="bootstrap.sh"

if [ "$DEBUG" = true ]; then
    echo
    echo "Reading base files... [bootstrap.sh]"
    echo
fi

# Loop the base folder and source all files
for file in $LOCAL_PATH/$LOCAL_FOLDER/*
do
    if [ $file != $LOCAL_PATH/$LOCAL_FOLDER/$BOOTSTRAP_FILE_NAME ]; then
        source $file
    fi
done

return 0
