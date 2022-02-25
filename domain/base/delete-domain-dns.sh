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

# Function to delete a DNS record
delete_domain_dns()
{
    local LOCAL_DOMAIN

    LOCAL_DOMAIN=${1:-$DOMAIN}

    [[ "$DEBUG" == true ]] && echo "Creating a DNS record for "$LOCAL_DOMAIN

    curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" \
        "https://api.digitalocean.com/v2/domains/"$LOCAL_DOMAIN

    RESPONSE="$(curl -X GET -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" \
        "https://api.digitalocean.com/v2/domains/$LOCAL_DOMAIN" | jq 'select(.domain != null) | .domain.name')"

    [[ "$DEBUG" == true ]] && echo "RESPONSE: "$RESPONSE

    if [[ -z "${RESPONSE}" ]]; then
        return 0
    else
        MESSAGE="Error on delete the dns record for $LOCAL_DOMAIN"
        return 1
    fi
}

