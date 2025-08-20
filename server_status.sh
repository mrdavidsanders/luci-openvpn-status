#!/bin/bash
> /tmp/ovpn_connstats
> /tmp/ovpn_connstats.json
> /tmp/ovpn_routestats
> /tmp/ovpn_routestats.json

#Connection Header Lines
cat /var/log/status.log | \
head -3 | \
tail +3 | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_connstats

# Data
cat /var/log/status.log | \
tail -n +4 | \
grep -B10000 -e ROUTING\ TABLE | \
head -n -1 | \
sort -t ',' | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_connstats

# Route Header Lines
cat /var/log/status.log | \
grep -A10000 -e ROUTING\ TABLE | \
grep -B10000 -e GLOBAL\ STATS | \
head -n2 | \
tail -1 | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_routestats

# Data
cat /var/log/status.log | \
grep -A10000 -e ROUTING\ TABLE | \
grep -B10000 -e GLOBAL\ STATS | \
tail +3 | \
sed 's/GLOBAL STATS//g' | \
sed "s/\s/-/g" | \
sort  -t ',' -k2b,2 -k3b,3 | \
tail +2 | \
sed 's/^/"/g' | \
sed 's/,/","/g' | \
sed 's/$/"/g' >> /tmp/ovpn_routestats

csvjson /tmp/ovpn_connstats | \
jq  '.[] | select(.["Common Name"])|( {(.["Common Name"]):  [.]} )' \
> /tmp/ovpn_connstats.json
csvjson /tmp/ovpn_routestats | \
jq  '.[] | select(.["Common Name"])|( {(.["Common Name"]):  [.]} )' \
> /tmp/ovpn_routestats.json

jq -s '(.[] | keys[]) as $k | reduce .[] as $item (null; .[$k] += $item[$k])' /tmp/ovpn_routestats.json /tmp/ovpn_connstats.json | jq -s 'flatten|add'|jq
