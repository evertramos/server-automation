#-----------------------------------------------------------------------
#
# Server Automation - https://github.com/evertramos/server-automation 
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos 
#
#-----------------------------------------------------------------------
#
# Be carefull when editing this file
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# This function has one main objective:
# 1. Load all functions in local script folder
#-----------------------------------------------------------------------

# Get Current directory
LOCAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

# Bootstrap file name
BOOTSTRAP_FILE_NAME="bootstrap.sh"

[[ "$DEBUG" == true ]] && echo "Reading local script files... [./localscript/bootstrap.sh]"

# Loop the base folder and source all files
for file in $LOCAL_PATH/*.sh
do
    if [[ $file != $LOCAL_PATH/$BOOTSTRAP_FILE_NAME ]]; then
        source $file
    fi
done

return 0

