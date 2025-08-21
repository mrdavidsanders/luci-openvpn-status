#!/bin/sh
GIT_REV='$Id$'
PKG_NAME="luci-openvpn-status"
LUA_LIB_DIR="/usr/lib/lua/"
LUCI_LUA_ADMIN_INDEX_DIR="/usr/lib/lua/luci/view/admin_status/index/"
TMP_DIR="/tmp/"
echo "Installing $PKG_NAME ($GIT_REV)"
echo

test -e /etc/openwrt_release && \
if [ "$(source /etc/openwrt_release; echo $DISTRIB_RELEASE|cut -c1-2)" -lt 23 ]; \
	then echo "Your OpenWRT version ($DISTRIB_RELEASE) may be too old"; \
fi ||  { echo "Not installing on non-OpenWRT system" && exit 1; }

test -e /usr/bin/whoami && \
if [ "$(whoami)" != "root" ]; then \ 
        echo "You need root privileges to install Lua Libs"; \ 
        exit 1; \
fi || echo "Skipping root user check"

PREREQ_PACKAGES="luci-lua-runtime lua"
for PKG in ${PREREQ_PACKAGES}; do
        echo "Checking for $PKG"
        PREREQ=`opkg list-installed ${PKG}`
        if [ "${PREREQ}" == "" ];
        then
                echo "${PKG} not installed!";
                exit 1
        fi
done
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
