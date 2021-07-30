#-----------------------------------------------------------------------
#
# Server Automation - https://github.com/evertramos/server-automation
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos
#
#-----------------------------------------------------------------------
#
# Be careful when editing this file, it is part of a bigger script!
#
#-----------------------------------------------------------------------

# ----------------------------------------------------------------------
# This function has one main objective:
# 1. Config ssh service in container
#
# You must/might inform the parameters below:
# 1. Container where the openssh will be managed
#
# ----------------------------------------------------------------------

local_config_openssh_service()
{
    local LOCAL_CONTAINER

    LOCAL_CONTAINER="${1:-null}"

    [[ $LOCAL_CONTAINER == "" || $LOCAL_CONTAINER == null ]] && echoerror "You must inform the required argument(s) to the function: '${FUNCNAME[0]}'"

    [[ "$DEBUG" == true ]] && echo "Update settings on sshd_config file"
    docker exec -it $LOCAL_CONTAINER sed -i '/PermitRootLogin\ prohibit-password/s/^#//' /etc/ssh/sshd_config
    docker exec -it $LOCAL_CONTAINER sed -i '/PermitTunnel/s/^#//' /etc/ssh/sshd_config
    docker exec -it $LOCAL_CONTAINER sed -i '/PermitTunnel/s/^#//' /etc/ssh/sshd_config
    docker exec -it $LOCAL_CONTAINER sed -i '/SyslogFacility/s/^#//' /etc/ssh/sshd_config
    docker exec -it $LOCAL_CONTAINER sed -i '/LogLevel/s/^#//' /etc/ssh/sshd_config
    docker exec -it $LOCAL_CONTAINER sed -i '/AuthorizedKeysFile/s/^#//' /etc/ssh/sshd_config
    docker exec -it $LOCAL_CONTAINER sed -i '/sftp-server/s/^/#/g' /etc/ssh/sshd_config

    return 0
}

