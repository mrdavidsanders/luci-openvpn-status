#!/bin/bash
> /tmp/ovpn_connstats
> /tmp/ovpn_connstats.json
> /tmp/ovpn_routestats
> /tmp/ovpn_routestats.json

#Connection Header Lines
cat /var/log/status.log | \
head -3 | \
tail +3 | \
sed 's/\ //g' | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_connstats

# Data
cat /var/log/status.log | \
sed -n '/Connected\ Since/,/ROUTING\ TABLE/p' | \
tail +2 | head -n-1 | \
sort -t ',' | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' \
>> /tmp/ovpn_connstats

# Route Header Lines
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

# Data
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
csvjoin -c CommonName \
        /tmp/ovpn_routestats \
        /tmp/ovpn_connstats  \
|csvjson| jq '.|map({"CommonName":.CommonName,Values:.})|group_by(.Values.CommonName)|map({"Common Name":.[0].CommonName,"Real Address":.[0].Values.RealAddress,"Connected Since":.[0].Values.ConnectedSince,"Last Ref":.[0].Values.LastRef,"Bytes Received":.[0].Values.BytesReceived,"Bytes Sent":.[0].Values.BytesSent,"Virtual Address":map(.Values.VirtualAddress)})'
