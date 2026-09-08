#!/bin/sh
AC_RED="\e[31m"
AC_GREEN="\e[32m"
AC_GRAY="\e[37m"
AC_WHITE="\e[97m"
AC_END="\e[0m"

# These vars should be overriden - don't put them here 
# unless you're sure! 
: ${SSH_USER:=""}
: ${SSH_HOST:=""}

# INTERVAL in seconds
# Runs per MAX_TRIES*INTERVAL
: ${INTERVAL:=15}
: ${MAX_TRIES:=3}

JSON_OUT='/tmp/openvpn_new.json'

if [ "$(echo ${SSH_USER})" != "" ] && [ "$(echo ${SSH_HOST})" != "" ]; then
    time=0
    LOG="${AC_GREEN}Getting JSON from ${AC_WHITE}${SSH_HOST}${AC_GREEN}: ${AC_END}"
    for j in $(seq 1 $MAX_TRIES); do
        OUTPUT=$(ssh -T ${SSH_USER}@${SSH_HOST}) && \
        echo $OUTPUT > $JSON_OUT && \
        LOG="$LOG ${AC_GREEN}$(printf '\xE2\x9C\x85')${AC_END}"   
        sleep $INTERVAL
        let "time=${time}+${INTERVAL}"
    done
    echo -e "$LOG"
fi
