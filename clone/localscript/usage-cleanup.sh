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
usage_cleanup()
{
    cat << USAGE >&2
Usage: 
    $SCRIPT_NAME [-s source_folder] [-d destination_folder] 
              [-u site_url | --filter="string"] [--local-only]
              [--all-sites] [--backup-id=$(date "+%Y%m%d_%H%M%S")]
              [--clean-storage] [--storage-only]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -s | --source       Location where all your sites's folders are
    -d | --destination  Location where all your BACKUP files are
    -u | --url          Site URL that should be liste
    --filter=""         The same as above (-u "string")
    --backup-id         The IDentification for you backup
                        [IMPORTANT] This backup id will delete the specific 
                        file with this id. 
                        The default value for the backup id is 'YearMonthDay'
    --all--sites        This option will clean backup files for all sites in your 
                        destination folder
    --local-only        Clean backup file only locally
    --clean-storage     Clean backup file on the ftp storage 
    --storage-only      Clean files ONLY  in the ftp storage. This option only
                        works when --local-only is NOT set.
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help

USAGE
    exit 1
}
