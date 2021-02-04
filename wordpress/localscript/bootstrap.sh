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

#-----------------------------------------------------------------------
# This script has one main objective:
# 1. Load all functions in local folder and subfolders
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Fill out local variables
#-----------------------------------------------------------------------
# Get Current directory
LOCAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

# Bootstrap file name
BOOTSTRAP_FILE_NAME="bootstrap.sh"

#-----------------------------------------------------------------------
# Debug message
#-----------------------------------------------------------------------
[[ "$DEBUG" == true ]] && "Reading base script files... [bootstrap.sh]"

#-----------------------------------------------------------------------
# Read files with extension '.sh'
#-----------------------------------------------------------------------
# Loop the base folder and source all files in root folder
for file in $LOCAL_PATH/*.sh
do
    [[ $file != $LOCAL_PATH/$BOOTSTRAP_FILE_NAME ]] && source $file
done

return 0