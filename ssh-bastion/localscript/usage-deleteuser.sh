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
usage_deleteuser()
{
    cat << USAGE >&2
${blue}

LOCAL FILE

Usage:
    $SCRIPT_NAME  [-c container_name     | --container=container_name        ]
                   [-u user_name          | --user-name=user_name             ]
                   [--remove-user-only] [--debug] [--silent]

    Alternatively you may inform the options below
    -c | --container        The SSH container name (default: 'ssh')
    -u | --user-name        User name that should be created in 'ssh' cotnainer
    --remove-user-only      This option will only remove a user from 'ssh' container
                            keeping user's access to all containeres with its key

    There is some debug options you may use in order to hide or show more details
    --debug                 Show script debug options
    --silent                Hide all script message

${reset}
USAGE
    exit 1
}
