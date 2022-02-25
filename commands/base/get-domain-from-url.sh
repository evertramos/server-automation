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

# Script to get the domain name from a URL

domain_get_domain_from_url()
{
    local LOCAL_URL

    LOCAL_URL="${1}"

    if [[ "$DEBUG" = true ]]; then
        echo "Getting the domain name from a URL."
    fi
    
    if [[ "$LOCAL_URL" != '' ]]; then
       DOMAIN_URL_RESPONSE="$(echo $LOCAL_URL | sed -e 's|^[^/]*//||' -e 's|/.*$||')"
    else
        if [[ "$SILENT" != true ]]; then
            echoerror "You must inform the URL in order the extract the domain name."
        fi
    fi
}

