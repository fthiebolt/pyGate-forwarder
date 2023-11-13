#!/bin/bash
#
# Git pull script with credentials management
# ===
# Notes:
# ===
# TODO:
# - regex with tokens to get taken into account
# ===
# F.Thiebolt    sep.23  adaptation to gitlab URLs
# F.Thiebolt    2016    initial release
#

_SCRIPTREV="231111"

#DEBUG=1

# Debug
if [ ${DEBUG:-0} -eq 1 ]; then
    exec &> >(tee -a /tmp/$(basename ${BASH_SOURCE[0]}).log)
    echo -e "\n--- $(date +"%d-%m-%Y %H:%M") --- $(basename ${BASH_SOURCE[0]}) ----------------------------------------------"
    echo -e "Nb input params = $#, \$1='$1', \$2='$2'"
    env
    echo -e ""
    # enable trace mode
    set -x
fi


echo -e "#\n#\tGIT-PULL | deploy script revision ${_SCRIPTREV:-'unknown'}\n#"

# Git related variables définitions
#GIT_REPOSITORY=$(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')

# credentials ?
_CRED_FILE="git-deploy-credentials.sh"
if [ -f ${CRED_FILE} ]; then
    echo -e "\n\tSourcing credentials config file ${_CRED_FILE} ..."
    source ${_CRED_FILE}
    [ ${DEBUG:-0} -eq 1 ] && { env; }
elif [ ${DEBUG:-0} -eq 1 ]; then
    echo -e "\n\tNO deploy credentials file ... continuing ..."
fi


# [dec.22] removed StrictHostKey checking
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# GIT set remote URL
if [[ ${GIT_DEPLOY_USERNAME} == "" && ${GIT_DEPLOY_TOKEN} == "" ]]; then
    echo -e "# NO deploy credentials detected ... simple git pull"
else
    # https://serverfault.com/questions/417241/extract-repository-name-from-github-url-in-bash
    re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)(.git)*$"
    if [[ $(git config --local remote.origin.url) =~ $re ]]; then    
        _protocol=${BASH_REMATCH[1]}
        _separator=${BASH_REMATCH[2]}
        _hostname=${BASH_REMATCH[3]}
        _user=${BASH_REMATCH[4]}
        _repo=${BASH_REMATCH[5]}
    fi
    _git_username=${GIT_DEPLOY_USERNAME}
    _git_token=${GIT_DEPLOY_TOKEN}
    _git_hostname=$(git config --local remote.origin.url|sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/')
    #_git_hostname=${_hostname}
    _git_path=${_repo}
    _git_remote_url="https://${_git_username}:${_git_token}@${_git_hostname}/${_git_path}"
    [ ${DEBUG:-0} -eq 1 ] && { env; }

    if [[ ${_git_hostname} != github* ]]; then
        git remote set-url origin ${_git_remote_url}
        [ $? -ne 0 ] && { echo -e "\n###ERROR: unable to set GIT remote url for repository '${_git_remote_url}' !!" >&2; exit 1; }
    fi
fi

git pull
[ $? -ne 0 ] && { echo -e "\n### git pull ERROR from REPO '$(git config --local remote.origin.url)' !" >&2; exit 1; }


# Debug
if [ ${DEBUG:-0} -eq 1 ]; then
    echo -e "--- $(date +"%d-%m-%Y %H:%M") -----------------------------------------------------------\n"
    # disable trace mode
    set +x
fi

