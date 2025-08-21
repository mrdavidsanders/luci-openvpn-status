#!/bin/sh
GIT_REV='$Id$'
PKG_NAME="luci-openvpn-status"
LUA_LIB_DIR="/usr/lib/lua/"
LUCI_LUA_ADMIN_INDEX_DIR="./test/"
TMP_DIR="/tmp/"
echo "Installing $PKG_NAME ($GIT_REV)"
echo
test -e /usr/bin/whoami && if [ "$(whoami)" != "root" ]; \
        then echo "You need root privileges to install Lua Libs"; \
        exit 1; fi || echo "Skipping root user check"

LUALIBS="openvpn.lua filesize.lua"
for LIB in ${LUALIBS}; do
        echo "Copying $LIB to $LUA_LIB_DIR"
        cp $LIB $LUA_LIB_DIR
done
HTMLPG="openvpn.htm"
for HTM in ${HTMLPG}; do
        echo "Copying $HTM to $LUCI_LUA_ADMIN_INDEX_DIR"
        cp $HTM $LUCI_LUA_ADMIN_INDEX_DIR
done
MISCF="openvpn_new.json"
for MF in ${MISCF}; do
        echo "Copying $MF to $TMP_DIR"
        cp $MF $TMP_DIR
done
echo
echo "$PKG_NAME succesfully installed"
