#!/usr/bin/env bash
#
# Deploy project as a systemd service
#
#   Note: we'll set the service file in /etc/<subdir>
# ===
# Links
#   - https://superuser.com/questions/1581577/running-two-tmux-sessions-as-systemd-service
#   - https://www.tecmint.com/create-systemd-service-linux/
# ===
# F.Thiebolt    nov.23  initial release
#

###
# Variables for users' customization
#BaseDir="_$(basename ${BASH_SOURCE[0]})"
_currentDir=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
serviceName=""

targetDIR="/etc/systemd/system/"
[ -d ${targetDir} ] || { echo -e "\n###ERROR: targetdir '${targetDir}' does not exists ... abort!" >&2; exit 1; } 


# Debug mode
[ "X${_debug}" = "X1" ] && { echo -e "\nDEBUG mode activated for ${BASH_SOURCE[0]} script"; set -x; }





set
printenv







# cancel debug mode ?
[ "X${_debug}" = "X1" ] && { set +x; }

