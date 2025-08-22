#!/bin/sh
# These vars should be overriden - don't put them here 
# unless you're sure!
 
: ${SSH_USER:=""}
: ${SSH_HOST:=""}

if [ "$(echo ${SSH_USER)" != "" && "$(echo ${SSH_HOST)" != "" ]; then
    JSON_OUT='/tmp/openvpn_new.json'
    VPN_CLIENT="$(ssh ${SSH_USER}@${SSH_HOST})"
    echo $VPN_CLIENT > $JSON_OUT 
fi

