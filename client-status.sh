#!/bin/sh

STATUS_FILE=/tmp/openvpn_clients.htm
VPN_CLIENTS="$(\ 
	ssh arkham.home.dsanders.uk cat /home/openvpn/status.log | \
	grep -A10000 -e ROUTING\ TABLE | \
	grep -B10000 -e GLOBAL\ STATS | \
	tail +3 | \
	sed 's/GLOBAL STATS//g' | \
	sed "s/\s/-/g";)"

> $STATUS_FILE
for client in $VPN_CLIENTS
do
    echo '<div class="tr">' >> $STATUS_FILE
    echo "<div class='td'>$(echo $client|awk -F',' '{print $1}')</div>" >> $STATUS_FILE
    echo "<div class='td'>$(echo $client|awk -F',' '{print $2}')</div>" >> $STATUS_FILE
    echo "<div class='td'>$(echo $client|awk -F',' '{print $3}')</div>" >> $STATUS_FILE
    echo "<div class='td'>$(echo $client|awk -F',' '{print $4}')</div>" >> $STATUS_FILE
    echo '</div>' >> $STATUS_FILE
done

