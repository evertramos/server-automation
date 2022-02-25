#-----------------------------------------------------------------------
#
# Server Automation - https://github.com/evertramos/server-automation
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos
#
#-----------------------------------------------------------------------
#
# Be careful when editing this file, it is part of a bigger script!
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# This script has one main objective:
# 1. Show the script usage (helper)
#-----------------------------------------------------------------------

usage_adduser()
{
    cat << USAGE >&2
${blue}
Usage:
    $SCRIPT_NAME   [-c container_name     | --container=container_name        ]
                 [-u user_name          | --user-name=user_name             ]
                 [-k "key_string"       | --key-string="key_string"         ]
                 [-f /path/to/key_file  | --key-file=/path/to/key_file      ]
                 [-s site_container     | --site-container=site_cotainer    ]
                 [--add-user-only] [--debug] [--silent]

    Alternatively you may inform the options below
    -c | --container        The SSH container name (default: 'ssh')
    -u | --user-name        User name that should be created in 'ssh' cotnainer
    -k | --key-string       The ssh pub key string (IN ONE LINE) 
    -f | --key-file         The ssh pub key file (ex. id_rsa.pub)
    -s | --site-container   The container name that 'user' shall have access to
                            [IMPORTANT] You may add multiple sites using the '-s'
                            option: 
                                ... -s container_1 -s container_2 -s container_3
                            If you do not inform this option you will be prompted 
                            to select the containers
    --add-user-only         This option will only add a user to the 'ssh' container
                            and will not prompt you to grant access to this 'user'
                            into to site's containers

    There is some debug options you may use in order to hide or show more details
    --debug                 Show script debug options
    --silent                Hide all script message

${reset}
USAGE
    exit 1
}
