#!/bin/bash

#-----------------------------------------------------------------------
#
# Testing script for basescript files
#
# Server Automation - https://github.com/evertramos/server-automation 
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos 
#
#-----------------------------------------------------------------------

# Bash settings (do not mess with it)
shopt -s nullglob globstar

# Get the script name and its file real path
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Source basescript functions
source $SCRIPT_PATH"/../basescript/bootstrap.sh"

# Source localscripts
#source $SCRIPT_PATH"/localscript/bootstrap.sh"

#run_function backup_check_tar_file_integrity /tmp/test.tar.gz
#run_function backup_decompress_file /tmp /tmp/test.tar.gz false


exit 0
