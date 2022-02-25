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

# Function to show the script usage
usage_revokeuseraccess()
{
    cat << USAGE >&2
${blue}

LOCAL FILE

Usage:
    $SCRIPT_NAME [-u user_name          | --user-name=user_name             ]
                        [-s site_container     | --site-container=site_cotainer    ]
                        [--all-sites] [--debug] [--silent]

    Alternatively you may inform the options below
    -u | --user-name        User name that should be created in 'ssh' cotnainer
    -s | --site-container   The container name that 'user' shall have access to
                            [IMPORTANT] You may add multiple sites using the '-s'
                            option: 
                                ... -s container_1 -s container_2 -s container_3
                            If you do not inform this option you will be prompted 
                            to select the containers 
    --all-sites             This option will remove user's accss from all sites

    There is some debug options you may use in order to hide or show more details
    --debug                 Show script debug options
    --silent                Hide all script message

${reset}
USAGE
    exit 1
}
