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

list_all_domains()
{
    if [ "$DEBUG" = true ]; then
        echo "Creating a DNS record for "$DOMAIN
    fi
    
    #curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" "https://api.digitalocean.com/v2/domains"  | jq 'select(.domains != null) | .domains[]?.name'
    curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" "https://api.digitalocean.com/v2/domains" \
        | jq 'select(.domains != null) | .domains[]? | {domain: .name, ip: (.zone_file | split("\n") | .[3] | split(" ") | .[4])}'

    return 0

    #RESPONSE="$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" \
    #    "https://api.digitalocean.com/v2/domains"  | jq 'select(.domains != null) | .domains[]?.name')"

    if [ "$DEBUG" = true ]; then
        echo "RESPONSE: "$RESPONSE
    fi

    if [ ! -z "${RESPONSE}" ]; then
        return 0
    else
        MESSAGE="Error on create the domain $DOMAIN"
        return 1
    fi
}

