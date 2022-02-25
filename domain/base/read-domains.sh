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

# Script to check if domain exists
read_all_domains ()
{

    if [ ! -z $1 ]; then
        if [ "$DEBUG" = true ]; then
            echo "Reading domain: "$1
        fi
   
        RESPONSE="$(curl -X GET -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" "https://api.digitalocean.com/v2/domains/"$1)"

        if [ "$DEBUG" = true ]; then
            echo "RESPONSE: "$RESPONSE
        fi
    else
        if [ "$DEBUG" = true ]; then
            echo "Reading all domains"
        fi
   
        RESPONSE="$(curl -X GET -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" "https://api.digitalocean.com/v2/domains")"

        if [ "$DEBUG" = true ]; then
            echo "RESPONSE: "$RESPONSE
        fi
    fi

}
