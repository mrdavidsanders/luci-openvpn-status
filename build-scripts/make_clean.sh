#!/bin/bash
# Clean
AC_RED="\e[31m"
AC_GREEN="\e[32m"
AC_GRAY="\e[37m"
AC_WHITE="\e[97m"
AC_END="\e[0m"
BUILD_DIR="./build"
rm -rf $BUILD_DIR
echo -e "${AC_GREEN}Deleted${AC_GRAY} ${BUILD_DIR}"

