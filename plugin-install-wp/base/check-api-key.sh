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

# Script to check if API KEY exists

check_api_key()
{
    if [[ "$DEBUG" = true ]]; then
        echo "Checking if the api key was set in .env file"
    fi
    
    if [[ "$API_KEY" == "" ]]; then
        echoerror "Please set the option API_KEY in your .env file in order to create new domain"
    fi
}
