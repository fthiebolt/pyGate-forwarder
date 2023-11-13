#!/bin/bash
#
# Simple GIT-PUSH helper script ;)
# ===
# Notes:
# ===
# TODO:
# - regex with tokens to take them into account
# ===
# F.Thiebolt    sep.23  adaptation to gitlab URLs
#                       now differentiating push origin URL :D
# F.Thiebolt    2016    initial release
#

# -- ORIGINAL SCRIPT SOURCE: https://bitbucket.org/fthiebolt/myhelpscripts/common-git-scripts

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


echo -e "#\n#\tGIT-PUSH | push script revision ${_SCRIPTREV:-'unknown'}\n#"
echo -e "#\t(script source https://fthiebolt@bitbucket.org/fthiebolt/myhelpscripts.git)\n#"


if [ "$#" == "0" ]; then
    msg='update'
else
    msg="$@"
fi


# [dec.22] removed StrictHostKey checking
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

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
_git_remote_url="https://${_git_hostname}/${_git_path}"
#_git_remote_url="https://${_git_username}:${_git_token}@${_git_hostname}/${_git_path}"

[ ${DEBUG:-0} -eq 1 ] && { env; }

if [[ ${_git_hostname} != github* ]]; then
    _cmd="git remote set-url --push origin ${_git_remote_url}"
    echo -e "Set REMOTE push URL:\n\t${_cmd}"
    ${_cmd}
    [ $? -ne 0 ] && { echo -e "\n###ERROR: unable to set GIT remote url for repository '${_git_remote_url}' !!" >&2; exit 1; }
fi

git add --all
[ $? -ne 0 ] && { echo -e "\n### git add ERROR from REPO '$(git config --local remote.origin.url)' !" >&2; exit 1; }
git commit -a -m "${msg}"
[ $? -ne 0 ] && { echo -e "\n### git commit ERROR from REPO '$(git config --local remote.origin.url)' !" >&2; exit 1; }
git push
[ $? -ne 0 ] && { echo -e "\n### git push ERROR from REPO '$(git config --local remote.origin.url)' !" >&2; exit 1; }


# Debug
if [ ${DEBUG:-0} -eq 1 ]; then
    echo -e "--- $(date +"%d-%m-%Y %H:%M") -----------------------------------------------------------\n"
    # disable trace mode
    set +x
fi



