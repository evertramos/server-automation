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

# Script to create a DNS record

domain_create_domain_dns()
{
    local LOCAL_DOMAIN
    
    if [[ ! -z $1 ]]; then
        LOCAL_DOMAIN=$1
    else
        LOCAL_DOMAIN=$DOMAIN
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Creating a DNS record for "$LOCAL_DOMAIN
    fi
    
    RESPONSE="$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" \
        -d "{\"name\":\"$LOCAL_DOMAIN\", \"ip_address\":\"$IPv4\"}" "https://api.digitalocean.com/v2/domains" \
        | jq 'select(.domain != null) | .domain.name')"

    if [ "$DEBUG" = true ]; then
        echo "RESPONSE: "$RESPONSE
    fi

    if [ ! -z "${RESPONSE}" ]; then
        return 0
    else
        MESSAGE="Error on create the domain $LOCAL_DOMAIN"
        return 1
    fi
}

