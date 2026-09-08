#!/bin/sh
# Run this in POSIX shell mode
AC_RED="\e[31m"
AC_GREEN="\e[32m"
AC_GRAY="\e[37m"
AC_WHITE="\e[97m"
AC_END="\e[0m"

PKG_MGR="apk"
PKG_NAME="luci-openvpn-status"
MODULE_VERSION=$(cat ./MODULE_VERSION)
test -e ./BUILD_VERSION && GIT_REV=$(cat BUILD_VERSION) || GIT_REV=dev
PKG_VERSION="${MODULE_VERSION}-${GIT_REV}"

LUA_LIB_DIR="/usr/lib/lua/"
LUCI_LUA_ADMIN_INDEX_DIR="/usr/lib/lua/luci/view/admin_status/index/"
TMP_DIR="/tmp/"
OWRT_MIN=23

echo -e "${AC_GREEN}Installing ${AC_WHITE} $PKG_NAME${AC_GREEN} Version ${AC_WHITE}($PKG_VERSION)"
echo -e

test -e /etc/openwrt_release && \
if [ "$(source /etc/openwrt_release; echo -e $DISTRIB_RELEASE|cut -c1-2)" -lt $OWRT_MIN ]; \
        then echo -e "${AC_WHITE}Your OpenWRT version ${AC_RED}($DISTRIB_RELEASE) ${AC_WHITE}may be too old"; \
fi ||  { echo -e "${AC_RED}Not installing on non-OpenWRT system${AC_END}" && exit 1; }

test -e /usr/bin/whoami && if [ "$(whoami)" != "root" ]; \
        then echo -e "${AC_RED}You need root privileges to install Lua Libs${AC_END}"; \
        exit 1; fi || echo -e "${AC_GRAY}Skipping root user check"

PREREQ_PACKAGES="luci-lua-runtime lua luac"
echo "PREREQS are $PREREQ_PACKAGES"
for PKG in $(echo $PREREQ_PACKAGES); do
        echo "Checking for $PKG"
        if [ "${PKG_MGR}" == "opkg" ];
        then
                PREREQ=`opkg list-installed ${PKG}`
        fi
        if [ "${PKG_MGR}" == "apk" ];
        then
                PREREQ=`${PKG_MGR} list ${PKG}`
        fi
        if [ "${PREREQ}" == "" ];
        then
                echo -e "${AC_RED}${PKG} not installed!${AC_END}";
                exit 1
        fi
done
LUALIBS="openvpn.lua filesize.lua"
test -e /usr/bin/luac && \
{ for LIB in ${LUALIBS}; do
        echo -e "${AC_WHITE}Compiling:${AC_GRAY} $LIB to $LUA_LIB_DIR"
        echo "luac -o ${LUA_LIB_DIR}${LIB} ${LIB}"
        luac -o "${LUA_LIB_DIR}${LIB}" ${LIB}
done } || \
{ echo -e "${AC_WHITE}Luac ${AC_GRAY} not found, libs will be unoptimised${AC_END}";
for LIB in ${LUALIBS}; do
        echo -e "${AC_WHITE}Copying:${AC_GRAY} $LIB to $LUA_LIB_DIR"
        cp ${LIB} "${LUA_LIB_DIR}${LIB}"
done }
HTMLPG="openvpn.htm"
for HTM in ${HTMLPG}; do
        echo -e "${AC_WHITE}Copying:${AC_GRAY} $HTM to $LUCI_LUA_ADMIN_INDEX_DIR"
        cp $HTM $LUCI_LUA_ADMIN_INDEX_DIR
        sed -i "s/{{VERSION}}/$PKG_NAME ($PKG_VERSION)/g" $LUCI_LUA_ADMIN_INDEX_DIR/$HTM
done
MISCF="openvpn_new.json"
for MF in ${MISCF}; do
        test -e $TMP_DIR/$MF && \
        echo -e "${AC_WHITE}Not overwriting existing $TMP_DIR$MF${AC_GRAY}" \
        || { echo -e "${AC_WHITE}Copying: ${AC_GRAY}$MF to $TMP_DIR"; \
        cp $MF $TMP_DIR; }
done
echo -e
echo -e "${AC_GREEN}$PKG_NAME ($PKG_VERSION) ${AC_WHITE}succesfully installed ${AC_END}"
echo -e

