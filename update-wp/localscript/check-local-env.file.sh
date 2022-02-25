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

# Script to check if the .env file exists in the current folder
check_local_env_file()
{
    [[ "$DEBUG" == true ]] && echo "Check if local '.env' file is set."

    if [[ -e .env ]]; then
        source .env
    else 
        MESSAGE="'.env' file not found! \n Cheers!"
        return 1
    fi
}

