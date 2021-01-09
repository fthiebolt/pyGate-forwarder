#!/bin/bash

# This script is a helper to update the Gateway_ID field of given
# JSON configuration file, as a EUI-64 address generated from the 48-bits MAC
# address of the device it is run from.
#
# Usage examples:
#       ./update_gwid.sh ./local_conf.json


#
# vars
local_conf_file="${1:-local_conf.json}"
[ -f ${local_conf_file} ] || { echo -s "\n###ERROR: unable to find json config file ${local_conf_file} ... aborting :(" >&2; exit 1; }
gwid=""


#
# functions

# returns a new GWID derived from host's mac address
get_gwid() {
    # get gateway ID from its MAC address to generate an EUI-64 address
    GWID_PREFIX="FFFE"
    GWID_MAC=$(ip link show eth0 | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3$4$5$6}')

    gwid="${GWID_PREFIX}${GWID_MAC}"

    #echo -e "in get_gwid, gwid = ${gwid}"

    return 0
}


#
# main
echo -e "\n=== [packet_forwarder] Gateway_ID setup ==="

get_gwid >& /dev/null
[ $? -ne 0 ] && { echo -e "\n###ERROR: unable to generate new Gateway_ID ?!?! aborting :(" >&2; exit 1; }
[ ${#gwid} -ne 16 ] && { echo -e "\n###ERROR: gwid (${gwid}) length does not match our requirements ... aborting :(" >&2; exit 1; }

echo -ne "\tupdating '${local_conf_file}' file with new GATEWAY_ID = ${gwid}\n\tOK[y/N]?: "
read -e -n 1 answer
[ "X${answer,,}" != "Xy" ] && { echo -e "Operation cancelled !"; exit 0; }


# replace last 8 digits of default gateway ID by actual GWID, in given JSON configuration file
sed -i 's/\(^\s*"gateway_ID":\s*"\).\{16\}"\s*\(,\?\).*$/\1'${gwid}'"\2/' ${local_conf_file}

echo -e "Gateway_ID set to ${gwid} in file '${local_conf_file}'"
echo -e "\tupdate lorawan server definition with this new gateway ..."
echo -e "\n\t... then launch packet forwarder: ./lora_pkt_fwd"

