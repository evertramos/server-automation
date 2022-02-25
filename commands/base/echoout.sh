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

# Script to show output messages
echoerror()
{
    # Check $SILENT mode
    if [ "$SILENT" = true ]; then
        $@
    else
        echo "${red}>>> -----------------------------------------------------${reset}"
        echo "${red}>>>${reset}"
        echo "${red}>>>[ERROR] $@${reset}" 1>&2; 
        echo "${red}>>>${reset}"
        echo "${red}>>> -----------------------------------------------------${reset}"
    fi
    exit 1;
}

# Echo attention
echowarning() 
{
    # Check $SILENT mode
    if [ "$SILENT" = true ]; then
        $@
    else
        echo "${yellow}>>> -----------------------------------------------------${reset}"
        echo "${yellow}>>>${reset}"
        echo "${yellow}>>>[WARNING] $@${reset}" 1>&2; 
        echo "${yellow}>>>${reset}"
        echo "${yellow}>>> -----------------------------------------------------${reset}"
    fi
    echo 
}

