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

# Script to show the usage funcion
usage_restore()
{
    cat << USAGE >&2
${blue}
Usage: 
    $SCRIPT_NAME [-s source_folder] [-d destination_folder] 
              [-f back_file_full_path]
              [-nu new_site_url]
              [--from-storage]
              [--no-backup] [--backup-if-running]
              [--with-www]
              [--filter="string"]
              [-rsf path_temp_folder]
              [--yes]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -s | --source       Location for the backup file
    -d | --destination  Location where you want restore the backup file
    -f | --file-name    Full path for the backup file you want to restore
    -nu | --new-url     This option will restore the backup file to a specific url
                        It will update all fields in the database from the restored 
                        files and also set the url at the wp-config.php
    --from-storage      List backup files from the backup storage 
    --no-backup         Run the script without backing up if there is a running site
    --backup-if-running Backup the site without prompt to the user if site is running
    --with-www          Set the 'www' to the new url informed
    --filter=""         In order to filter the list of foler/URL you may inform the
                        option '--filter' to show only the ones that contains a 
                        certain string.
    -rsf                This option should only be used to change the basic option
                        set in the .env file to a new temporary folder that will be 
                        used by the script to restore the backup
                        [IMPORTANT] The folder should be empty and it will be 
                        totally ereased after the script execution
    --yes               Set "yes" to all, use it with caution
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help

${reset}
USAGE
    exit 1
}
