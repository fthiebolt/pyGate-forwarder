#!/usr/bin/env bash
#
# Deploy project as a systemd service
#
# ===
# Notes
#   - with tmux2.6, service won't start without RemainAfterExit=yes
#   - we'll set the service file in /etc/systemd/system/
#   - we were currently running on a Buster/sid on Jetson nano (2020)
# ===
# Links
#   - https://gist.github.com/lionell/34c6d2bc58df11462fb73d034b2d21d1
#   - https://superuser.com/questions/1581577/running-two-tmux-sessions-as-systemd-service
#   - https://www.tecmint.com/create-systemd-service-linux/
# ===
# F.Thiebolt    nov.23  initial release
#

###
# Variables for users' customization
_debug=${debug:-0}

_startNow=${_startnow:-0}

#BaseDir="_$(basename ${BASH_SOURCE[0]})"
_currentDir=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
serviceName=""

targetDir="/etc/systemd/system"
[ -d ${targetDir} ] || { echo -e "\n###ERROR: targetdir '${targetDir}' does not exists ... abort!" >&2; exit 1; } 

_cmd="cd ${_currentDir}; ./reset_pygate.py; cd packet_forwarder/lora_pkt_fwd; ./lora_pkt_fwd"
#_cmd="date; cd ${_currentDir}; ls -l; sleep 180"
_startNow=1

# Debug mode
[ "X${_debug}" = "X1" ] && { echo -e "\nDEBUG mode activated for ${BASH_SOURCE[0]} script"; set -x; }

# extract repository name
re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)(.git)*$"
if [[ $(git config --local remote.origin.url) =~ $re ]]; then    
    _protocol=${BASH_REMATCH[1]}
    _separator=${BASH_REMATCH[2]}
    _hostname=${BASH_REMATCH[3]}
    _user=${BASH_REMATCH[4]}
    _repo=${BASH_REMATCH[5]}

    serviceName=${_repo/%.git/}
fi

[ -z "${serviceName}" ] && { echo -e "\n###ERROR: unable to determine serviceName ?!?! ... abort!" >&2; exit 1; }
serviceFile="${targetDir}/${serviceName}.service"

#set
#printenv

echo -e "#\n#\t'${serviceName}' systemd service setup"
echo -e "#\tcurrent directory: ${_currentDir}"
echo -e "#\n\tsystemd service file: ${serviceFile}"
echo -e "#"

cat > ${serviceFile} << EOF
[Unit]
Description=${serviceName} LoRaWAN service
After=network-online.target
Wants=network-online.target

[Service]
#Type=oneshot
Type=forking
RemainAfterExit=yes
User=root
ExecStart=/usr/bin/tmux -f /root/.tmux.conf new-session -s ${serviceName} -d '${_cmd}'
ExecStop=/usr/bin/tmux -f /root/.tmux.conf kill-session -t ${serviceName}

[Install]
WantedBy=multi-user.target
EOF
chmod a-x ${serviceFile}
cat ${serviceFile}

# launch service
systemctl daemon-reload
systemctl disable --now ${serviceName}
systemctl enable ${serviceName}

# do we start immediately ?
if [ "X${_startNow}" == "X1" ]; then
    systemctl start ${serviceName}
    sleep 1
    systemctl -q is-active ${serviceName} >& /dev/null
    [ $? -ne 0 ] && { echo -e "\n###ERROR: service '${serviceName}' does not start ?!?! ... abort!" >&2; exit 1; }

    echo -e "#\n# service '${serviceName}' started in a tmux session\n"
    tmux ls
else
    echo -e "#\n# service '${serviceName}' enabled to start upon next reboot."
    echo -e "\n\tfor an immediate start of service:\n\t\tsystemctl start ${serviceName}"
fi

# cancel debug mode ?
[ "X${_debug}" = "X1" ] && { set +x; }

