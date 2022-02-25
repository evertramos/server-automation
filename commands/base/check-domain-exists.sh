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
domain_check_domain_exists()
{
    local LOCAL_DOMAIN
    
    if [[ ! -z $1 ]]; then
        LOCAL_DOMAIN=$1
    else
        LOCAL_DOMAIN=$DOMAIN
    fi
    
    if [[ "$DEBUG" == true ]]; then
        echo "Checking if domain: "$LOCAL_DOMAIN" exists"
    fi
   
    RESPONSE="$(curl -X GET -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" \
        "https://api.digitalocean.com/v2/domains/$LOCAL_DOMAIN" | jq 'select(.domain != null) | .domain.name')"

    if [ "$DEBUG" = true ]; then
        echo "RESPONSE: "$RESPONSE
    fi

    if [ ! -z "${RESPONSE}" ]; then
        DOMAIN_EXIST=true
        return 0
    else
        DOMAIN_EXIST=false
        # If domain doesn´t exist creat it if error on create then show message
        #MESSAGE="This domain $DOMAIN does not exist in your account."
        #return 1
        return 0
    fi
}

