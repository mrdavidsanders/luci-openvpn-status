#!/bin/sh
GIT_REV='$Id$'
PKG_NAME="luci-openvpn-status"
LUA_LIB_DIR="/usr/lib/lua/"
LUCI_LUA_ADMIN_INDEX_DIR="./test/"
echo "Installing $PKG_NAME ($GIT_REV)"
echo

echo
LUALIBS="openvpn.lua filesize.lua"
for LIB in ${LUALIBS}; do
        echo "Copying $LIB to $LUA_LIB_DIR"
        cp $LIB $LUA_LIB_DIR
done

echo "Copying openvpn.htm to $LUCI_LUA_ADMIN_INDEX_DIR"
cp openvpn.htm $LUCI_LUA_ADMIN_INDEX_DIR
echo
echo "$PKG_NAME succesfully installed"
