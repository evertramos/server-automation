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

# Script to check if the .env file exists in the current folder
check_local_env_file()
{
    
    if [ "$DEBUG" = true ]; then
        echo "Check if '.env' file is set."
    fi
    if [ -e .env ]; then
        source .env
    else 
        MESSAGE="'.env' file not found!"
        return 1
    fi
}

