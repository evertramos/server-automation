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

# Script to check if there is another instance of the script running
check_running_script() 
{
    
    if [ "$DEBUG" = true ]; then
        echo "Check if there is another instance of the script running..."
    fi

    PID=$SCRIPT_PATH/$PID_FILE
    
    if [ "$DEBUG" = true ]; then
        echo "pid: "$PID
    fi

    if [ -e "$PID" ]; then
        MESSAGE="Script already running."
        return 1
    fi
}
