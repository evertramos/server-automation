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

# Script to show the usage function
usage_backup()
{
    cat << USAGE >&2
${blue}
Usage: 
    $SCRIPT_NAME [-s source_folder] [-d destination_folder] 
              [-u site_url] [--all-sites]
              [--backup-id=$(date "+%Y%m%d_%H%M%S")]
              [--send-storage] [--local-only]
              [--delete-local]
              [--filter="string"]
              [--yes]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -s | --source       Location where all your sites's folders are
    -d | --destination  Location where you want to place your local backup files
    -u | --url          Site URL that should backup
                        set the 'SITES_FOLDER' path in your '.env' file.
    --backup-id         The IDentification for you backup
                        [IMPORTANT] It is always recommended you use an id for your 
                        backups, this way you will be able to identity your backup files
                        The default value for the backup id is 'YearMonthDay'
    --all--sites        This option will backup all your sites in your source folder
                        [VERY IMPORANT] This option takes a lot of space in your disk
                        before you use it make sure you have enough space left to 
                        backup all your sites at once.
    --local-only        Backup only in local server, do not send to backup storage 
    --send-storage      Send backup file to ftp storage 
    --delete-local      Delete local file after backup is done. This option only 
                        works when --local-only is NOT set.
    --filter=""         In order to filter the list of foler/URL you may inform the
                        option '--filter' to show only the ones that contains a 
                        certain string.
    --yes               Set "yes" to all, use it with caution
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help

${reset}
USAGE
    exit 1
}
