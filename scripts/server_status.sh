#!/bin/bash

# Requires https://github.com/medialab/xan  (==Very Fast)
# CSVLIB="xan"
# Or https://github.com/wireservice/csvkit  (!=Very Fast)
# CSVLIB="csvkit"

: ${STATUS_LOG_LOCATION:="/var/log"}
: ${STATUS_LOG_NAME:="status.log"}
: ${CSVLIB:="xan"}

# Clear the stats
> /tmp/ovpn_connstats
> /tmp/ovpn_routestats

# Force stat refresh
OVPN_PID=$(cat /var/run/openvpn/server.pid)
sudo kill -USR2 $OVPN_PID

# Get Connection Header Lines
cat /var/log/status.log | \
head -3 | \
tail +3 | \
sed 's/\ //g' | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_connstats

# Get Connection Data
cat /var/log/status.log | \
sed -n '/Connected\ Since/,/ROUTING\ TABLE/p' | \
tail +2 | head -n-1 | \
sort -t ',' | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' \
>> /tmp/ovpn_connstats

# Get Route Header Lines
cat /var/log/status.log | \
grep -A10000 -e ROUTING\ TABLE | \
grep -B10000 -e GLOBAL\ STATS | \
head -n2 | \
tail -1 | \
awk -F ',' {'printf "%s,%s,%s,%s\n",$2,$1,$3,$4'} | \
sed 's/\ //g' | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_routestats

# Get Route Data
cat /var/log/status.log | \
sed -n '/Last\ Ref/,/GLOBAL\ STATS/p' | \
tail +2 | head -n-1 | \
awk -F ',' {'printf "%s,%s,%s,%s\n",$2,$1,$3,$4'} | \
sort -t ',' |  \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' \
>> /tmp/ovpn_routestats

#Join
if [[ "${CSVLIB}" == "xan" ]]; then 
        xan join CommonName /tmp/ovpn_connstats CommonName /tmp/ovpn_routestats | \
        xan to json | \
        jq '.|map({"CommonName":.CommonName,Values:.})|group_by(.Values.CommonName)|map({"Common Name":.[0].CommonName,"Real Address":.[0].Values.RealAddress,"Connected Since":.[0].Values.ConnectedSince,"Last Ref":.[0].Values.LastRef,"Bytes Received":.[0].Values.BytesReceived,"Bytes Sent":.[0].Values.BytesSent,"Virtual Address":map(.Values.VirtualAddress)})'
elif [[ "${CSVLIB}" == "csvkit" ]]; then
        csvjoin -c CommonName /tmp/ovpn_connstats /tmp/ovpn_routestats | \
        csvjson | \
        jq '.|map({"CommonName":.CommonName,Values:.})|group_by(.Values.CommonName)|map({"Common Name":.[0].CommonName,"Real Address":.[0].Values.RealAddress,"Connected Since":.[0].Values.ConnectedSince,"Last Ref":.[0].Values.LastRef,"Bytes Received":.[0].Values.BytesReceived,"Bytes Sent":.[0].Values.BytesSent,"Virtual Address":map(.Values.VirtualAddress)})'
fi
