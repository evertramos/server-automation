#!/bin/bash

[[ ! "$1" == '' ]] && echo "df -h" | sftp $1 || echo "Please inform the servername"

exit 0

