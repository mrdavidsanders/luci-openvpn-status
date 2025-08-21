#!/bin/sh
SSH_USER=root
SSH_HOST=openvpn.home.dsanders.uk
JSON_OUT='/tmp/openvpn_new.json'
VPN_CLIENT="$(ssh ${SSH_USER}@${SSH_HOST} /root/openvpn_routes.sh)"
echo $VPN_CLIENT > $JSON_OUT 
