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
    $SCRIPT_NAME -f ssh_file_name your_new_url.com [-u your_site_url]
                 [-s source_folder] [-d destination_folder]
                 [--no-start] [--wp-debug] [--debug] [--silent]

    Or use long options:
    $SCRIPT_NAME --new-url=your_new_url.com [--url=your_site_url] 
                 [--source=source_folder] [--destination=destination_folder]
                 [--no-start] [--wp-debug] [--debug] [--silent]

    Recommended
    -nu | --new-url         The new URL for the clone site

    Alternatively you may inform the options below
    -u | --url              The new url for the cloning site
    -s | --source           Folder where the docker-compose.yml for the running site is located
    -d | --destination      Folder where the clone site will be located
    -h | --help             Display this help
    --no-start              Clone the site but does not start the docker-compose services
                            [WARNING!] Careful when cloning sites with the same URL.
                            It is recommended you ALWAYS USE the --new-url option.

    There is some debug options you may use in order to hide or show more details
    --wp-debug              Turn WP_DEBUG option to true on wp-config file
    --debug                 Show script debug options
    --silent                Hide all script message

${reset}
USAGE
    exit 1
}
