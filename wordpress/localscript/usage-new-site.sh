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
# Be carefull when editing this file, it is part of a bigger script!
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# This script has one main objective:
# 1. Show the script usage (helper)
#-----------------------------------------------------------------------

usage_new_site()
{
    cat << USAGE >&2
${blue}
Usage:
    $SCRIPT_NAME -nu your_new_url.com 
                [-d destination_folder]
                [--git-repo="https://github.com/evertramos/docker-wordpress.git"]
                [--git-tag="v1.0"]
                [--site-image="wordpress"] [--site-version="latest"]
                [--db-image="mariadb"] [--db-version="latest"]
                [-csut "YOU_UNIQUE_STRING"]
                [--with-www] [--yes]
                [--debug] [--silent]

    Required
    -nu | --new-url         The new site URL

    Alternatively you may inform the options below
    -d | --destination      Folder where the new site files will be located
    --git-repo              Git repot the site will clone from
    --git-tag               Git tag or branch version 
    --site-image            Docker image for the site (default: wordpress)
    --site-version          Version for site image
    --db-image              Docker image for the database (default: mariadb)
    --db-version            Version for database image
    -csut                   Specify the unique docker tag (services and containers)
                            Long form can be used: '--compose-service-unique-tag='
    --with-www              Set the 'www' to the site url
    --yes                   Set "yes" to all, use it with caution
    --debug                 Show script debug options
    --silent                Hide all script message
    -h | --help             Display this help

${reset}
USAGE
    exit 1
}
