#!/bin/sh
GIT_REV='$Id$'
PKG_NAME="luci-openvpn-status"
LUA_LIB_DIR="/usr/lib/lua/"
LUCI_LUA_ADMIN_INDEX_DIR="/usr/lib/lua/luci/view/admin_status/index/"
echo "Installing $PKG_NAME ($GIT_REV)"
echo

test -e /etc/openwrt_release && ISWRT=1 || ISWRT=0
if [ $ISWRT -eq 0 ]; then
        echo "Not installing on non-OpenWRT system";
        exit
fi

PREREQ_PACKAGES="luci-lua-runtime lua"
for PKG in ${PREREQ_PACKAGES}; do
        echo "Checking for $PKG"
        PREREQ=`opkg list-installed ${PKG}`
        if [ "${PREREQ}" == "" ];
        then
                echo "${PKG} not installed!";
                exit -1
        fi
done
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
