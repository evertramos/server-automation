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

# Script to work with PID
system_save_pid() {
    echo $$ > $SCRIPT_PATH/$PID_FILE
}

system_delete_pid() {
    rm -f $SCRIPT_PATH/$PID_FILE
}
