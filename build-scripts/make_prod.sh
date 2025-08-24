#!/bin/bash
# Produce prod module
AC_RED="\e[31m"
AC_GREEN="\e[32m"
AC_GRAY="\e[37m"
AC_WHITE="\e[97m"
AC_END="\e[0m"

PKG_NAME="luci-openvpn-status"
MODULE_VERSION=$(cat ./MODULE_VERSION)
test -e ./GIT_REV && GIT_REV=$(cat ./GIT_REV) || GIT_REV=$(date +%s)
PKG_VERSION="${MODULE_VERSION}-${GIT_REV}"


echo -e "${AC_GREEN}Building: ${AC_WHITE}$PKG_NAME ${AC_GREEN}Version: ${AC_WHITE}$PKG_VERSION" >&2
echo >&2
PRODFILES="scripts/client-status.sh \
           scripts/crontab.example  \
	   scripts/server_status.sh \
           scripts/install.luci.sh  \
           scripts/openvpn_new.json \
           htm/openvpn.htm          \
           MODULE_VERSION           \
	   libs/filesize.lua        \
	   libs/openvpn.lua"

BUILD_DIR="./build/${PKG_NAME}_${PKG_VERSION}"
echo -e "${AC_GREEN}Building in ${AC_WHITE}$BUILD_DIR" >&2
mkdir -p $BUILD_DIR >&2
echo  $GIT_REV > $BUILD_DIR/BUILD_VERSION

echo >&2
echo -e "${AC_GREEN}Copying files $AC_GRAY" >&2
for F in $PRODFILES; do
    cp -v $F $BUILD_DIR/ >&2
done

echo >&2
LUAMODS=`ls $BUILD_DIR/*.lua `
echo -e "${AC_GREEN}Remove debug from prod Lua modules" >&2
for MOD in $LUAMODS; do
	echo -e "${AC_WHITE}$MOD" >&2
	sed -i "s/dprint(\".*)//g" $MOD
	luamin -f $MOD > $MOD.min
    cp $MOD.min $MOD
    rm $MOD.min
done

echo >&2
echo -e "${AC_GREEN}Creating .tgz archive $AC_GRAY" >&2
cd ./build 
tar -cvzf ${PKG_NAME}_${PKG_VERSION}.tgz ./${PKG_NAME}_${PKG_VERSION}/ >&2
echo >&2
cd ..
echo -e "${AC_GREEN}Removing temporary build dir: ${AC_WHITE}${BUILD_DIR}" >&2
rm -rf $BUILD_DIR
echo >&2
echo -e "${AC_GREEN}Built package: ${AC_WHITE}./build/${PKG_NAME}_${PKG_VERSION}.tgz" >&2
echo >&2
cd ..
echo "./build/${PKG_NAME}_${PKG_VERSION}.tgz" >&1


