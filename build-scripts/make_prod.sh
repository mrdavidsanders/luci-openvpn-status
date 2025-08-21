#!/bin/bash
# Produce prod module
MODULE_VERSION=$(cat ./MODULE_VERSION)
GIT_REV=$(git log -n 1 --format=%H)

PKG_VERSION="${MODULE_VERSION}-git-${GIT_REV}"
PKG_NAME="luci-openvpn-status"

PRODFILES="scripts/client-status.sh \
	   scripts/crontab.example  \
	   scripts/server_status.sh \
           scripts/install.luci.sh  \
           scripts/openvpn_new.json \
           htm/openvpn.htm 	    \
           MODULE_VERSION           \
	   libs/filesize.lua        \
	   libs/openvpn.lua"

BUILD_DIR="./build/$PKG_NAME-$PKG_VERSION"
mkdir -p $BUILD_DIR 1>&2
echo $GIT_REV > $BUILD_DIR/BUILD_VERSION

for F in $PRODFILES; do
    cp -v $F $BUILD_DIR/ 1>&2
done

LUAMODS=`ls $BUILD_DIR/*.lua `
echo "Remove debug from prod Lua modules" 1>&2
for MOD in $LUAMODS; do
	echo "Module: $MOD" 1>&2
	sed -i "s/dprint(\".*)//g" $MOD
	lua-format -i $MOD
done

cd ./build 
tar -cvzf $PKG_NAME-$PKG_VERSION.tgz ./$PKG_NAME-$PKG_VERSION/ 1>&2
cd ..
echo "./build/$PKG_NAME-$PKG_VERSION.tgz"

