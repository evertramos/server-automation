# This file is part of a bigger script!
#
# Be careful when editing it

# ----------------------------------------------------------------------
#   
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>     
#
# Copyright Evert Ramos 
#
# ----------------------------------------------------------------------

# Script to load all functions in base script folder

# Get Current directory
LOCAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

# Bootstrap file name
BOOTSTRAP_FILE_NAME="bootstrap.sh"

if [[ "$DEBUG" == true ]]; then
    echo
    echo "Reading base script files... [bootstrap.sh]"
    echo
fi

# Loop the base folder and source all files
for file in $LOCAL_PATH/*.sh
do
    if [[ $file != $LOCAL_PATH/$BOOTSTRAP_FILE_NAME ]]; then
        source $file
    fi
done

return 0

