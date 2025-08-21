#!/bin/sh
# Run this in POSIX shell mode

MODULE_VERSION=$(cat ./MODULE_VERSION)
GIT_REV='$Id$'
GIT_REV="${MODULE_VERSION}-git-${GIT_REV#?????}"

PKG_VERSION=$(echo "${GIT_REV%??}")
PKG_NAME="luci-openvpn-status"
LUA_LIB_DIR="/usr/lib/lua/"
LUCI_LUA_ADMIN_INDEX_DIR="./test/"
TMP_DIR="/tmp/"

echo "Installing $PKG_NAME ($PKG_VERSION)"
echo
test -e /usr/bin/whoami && if [ "$(whoami)" != "root" ]; \
        then echo "You need root privileges to install Lua Libs"; \
        exit 1; fi || echo "Skipping root user check"

LUALIBS="openvpn.lua filesize.lua"
for LIB in ${LUALIBS}; do
        cp -v $LIB $LUA_LIB_DIR
done
HTMLPG="openvpn.htm"
for HTM in ${HTMLPG}; do
        cp -v $HTM $LUCI_LUA_ADMIN_INDEX_DIR
        sed -i "s/{{VERSION}}/$PKG_NAME ($PKG_VERSION)/g" $LUCI_LUA_ADMIN_INDEX_DIR/$HTM
done
MISCF="openvpn_new.json"
for MF in ${MISCF}; do
        test -e $TMP_DIR/$MF && \
        echo "Not overwriting existing $TMP_DIR$MF" \
        || cp -v $MF $TMP_DIR
done
echo
echo "$PKG_NAME ($PKG_VERSION) succesfully installed"
