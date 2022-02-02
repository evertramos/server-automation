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

usage_keygen()
{
    cat << USAGE >&2
${blue}
Usage:
    $SCRIPT_NAME -s server_connection_string [-sp server_password]
                 [-k ssh_key_file_name] [-kp key_passphrase]
                 [--yes] [--debug] [--silent]

    Required
    -s  | --server          The backup server connection string as of '<user>@<server>'

    Alternatively you may inform the options below
    -k  | --key-name        The key name that will be created
    -kp | --passphrase      The key passphrase
    -sp | --server-password The backup server password
                            [WARNING!] Be careful when using this option once this
                            information could be visible in logs, bash history, or
                            even process inspection.

    There is some debug options you may use in order to hide or show more details
    --yes                   Set "yes" to all, use it with caution
    --debug                 Show script debug options
    --silent                Hide all script message
    -h | --help             Display this help

${reset}
USAGE
    exit 1
}
