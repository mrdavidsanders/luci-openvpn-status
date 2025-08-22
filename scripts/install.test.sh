#!/bin/sh
# Run this in POSIX shell mode
AC_RED="\e[31m"
AC_GREEN="\e[32m"
AC_GRAY="\e[37m"
AC_WHITE="\e[97m"
AC_END="\e[0m"

PKG_NAME="luci-openvpn-status"
MODULE_VERSION=$(cat ./MODULE_VERSION)
test -e ./BUILD_VERSION && GIT_REV=$(cat BUILD_VERSION) || GIT_REV=dev
PKG_VERSION="${MODULE_VERSION}-${GIT_REV}"

LUA_LIB_DIR="/usr/share/lua/5.1/"
LUCI_LUA_ADMIN_INDEX_DIR="./test"
TMP_DIR="./test/"

echo -e "${AC_GREEN}Installing ${AC_WHITE} $PKG_NAME${AC_GREEN} Version ${AC_WHITE}($PKG_VERSION)"
echo -e
test -e /usr/bin/whoami && if [ "$(whoami)" != "root" ]; \
        then echo -e "${AC_RED}You need root privileges to install Lua Libs${AC_END}"; \
        exit 1; fi || echo -e "${AC_GRAY}Skipping root user check"

echo -e "${AC_GRAY}"
LUALIBS="./libs/openvpn.lua ./libs/filesize.lua"
for LIB in ${LUALIBS}; do
        cp -v $LIB $LUA_LIB_DIR
done
HTMLPG="openvpn.htm"
for HTM in ${HTMLPG}; do
        cp -v "./htm/$HTM" $LUCI_LUA_ADMIN_INDEX_DIR
        sed -i "s/{{VERSION}}/$PKG_NAME ($PKG_VERSION)/g" $LUCI_LUA_ADMIN_INDEX_DIR/$HTM
done
MISCF="openvpn_new.json"
for MF in ${MISCF}; do
        test -e $TMP_DIR/$MF && \
        echo -e "${AC_WHITE}Not overwriting existing $TMP_DIR$MF${AC_GRAY}" \
        || cp -v ./scripts/$MF $TMP_DIR
done
echo -e
echo -e "${AC_WHITE}$PKG_NAME ($PKG_VERSION) succesfully installed ${AC_END}"
echo -e

