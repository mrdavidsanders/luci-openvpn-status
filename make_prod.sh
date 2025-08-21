#!/bin/bash
# Produce prod module
MODULE_VERSION=$(cat ./MODULE_VERSION)
GIT_REV='$Id$'
GIT_REV="${MODULE_VERSION}-git-${GIT_REV#?????}"

PKG_VERSION=$(echo "${GIT_REV%??}")
PKG_NAME="luci-openvpn-status"

PRODFILES="client-status.sh install.luci.sh server_status.sh crontab.example filesize.lua openvpn.htm openvpn.lua openvpn_new.json MODULE_VERSION"
mkdir -p build
for F in $PRODFILES; do
    cp -v $F ./build/
done

LUAMODS="openvpn.lua filesize.lua"
echo "Remove debug from prod Lua modules"
for MOD in $LUAMODS; do
	echo "Module: $MOD"
	sed -i "s/dprint(\".*)//g" ./build/openvpn.lua
	lua-format -i ./build/openvpn.lua
done


