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
usage_cleanup()
{
    cat << USAGE >&2
${blue}
Usage: 
    $SCRIPT_NAME [-d destination_folder] 
              [-u site_url | --filter="string"]
              [--clean-storage]
              [--local-only] [--storage-only]
              [--all-sites] [--backup-id=$(date "+%Y%m%d_%H%M%S")]
              [--yes]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -d | --destination  Location to your BACKUP files
    -u | --url          Site URL that should be listed
    --filter=""         The same as above (-u "string")
    --backup-id         The backup identification
                        [IMPORTANT] This backup id will delete the specific 
                        file with this id. The default id value is 
                        'YearMonthDay_HourMinuteSeconds'
    --all--sites        This option will clean backup files for all sites in your 
                        destination folder
    --local-only        Clean backup file only locally
    --clean-storage     Clean backup file on the backup storage 
    --storage-only      Clean files ONLY  in the backup storage. This option only
                        works when --local-only is NOT set.
    --yes               Set "yes" to all, use it with caution
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help

${reset}
USAGE
    exit 1
}
