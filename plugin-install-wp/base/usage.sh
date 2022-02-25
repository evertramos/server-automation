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
${blue}
Usage:
    $SCRIPT_NAME -u your_site_url [-s plugig_list_folder] [-d site_folder]
                                  [-f plugin_list_file_name] [-g git_repo]
                                  [--debug] [--silent] [--start]

    Required
    -u | --url                  Site url that should be located in the 'SITES_FOLDER' 
                                configures in your .env file.
                                The folder name must match with the site url, 
                                otherwise please use -s option.
    -s | --source               Folder where your the plugin file list is located
                                or inform the file name option (-f)
                                or inform the file git repo option (-g)

    Alternatively you may inform the options below
    -d | --destination          Folder where your sites is located 
    -f | --file                 The file with a list of plugins
                                [IMPORTANT] The list should be set in the file with
                                line break.
    -g | --git-repo             Git repo that contains the WordPress Plugin
                                [IMPORTANT] If your git repo is private you must set your 
                                credentials or set a ssh key to your git repo.
    --activate                  Activate the plugin when installing

    There is some debug options you may use in order to hide or show more details
    --debug                     Show all steps of the script execution
    --silent                    Hide all message
    -h | --help                 Display this help
${reset}
USAGE
    exit 1
}
