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

# Script to check if docker is running
DOCKER_COMMAND="docker"

# Check if Docker is installed in the System
check_docker()
{
    if [ "$DEBUG" = true ]; then
        echo "Check if '$DOCKER_COMMAND' is installed and running."
    fi
    if [ ! -x "$(command -v "$DOCKER_COMMAND")" ]; then
        MESSAGE="'docker' is not installed!"
        return 1
    fi

    if [ ! "$(systemctl is-active "$DOCKER_COMMAND")" == "active" ]; then
        MESSAGE="'docker' is not running..."
        return 1
    fi
}
