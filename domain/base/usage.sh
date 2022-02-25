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

# Script to show the usage function
usage()
{
    cat << USAGE >&2
Usage:
    $SCRIPT_NAME -s source_folder -d destination_folder [-u new_url] [-u your_new_url.com] 
                 [-d] [--debug] [--silent]

    Required
    -s | --source               Folder where the docker-compose.yml for the running site is located
    -d | --destination          Folder where the clone site will be located

    Alternatively you may inform the options blow
    -u | --url                  new url for the cloning site
    -h | --help                 Display this help
    -d | --wp-debug             Turn WP_DEBUG option to true on wp-config file

    There is some debug options you may use in order to hide or show more details
    --debug                     Show script debug options
    --silent                    Hide all script message

USAGE
    exit 1
}
