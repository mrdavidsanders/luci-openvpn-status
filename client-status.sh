#!/bin/sh

STATUS_FILE=/tmp/openvpn_clients.htm
VPN_CLIENTS="$(\
        ssh openvpn.home.dsanders.uk cat /var/log/status.log | \
        grep -A10000 -e ROUTING\ TABLE | \
        grep -B10000 -e GLOBAL\ STATS | \
        tail +3 | \
        sed 's/GLOBAL STATS//g' | \
        sed "s/\s/-/g" | \
	sort -k 2;)"

> $STATUS_FILE
for client in $VPN_CLIENTS
do
    echo '<tr class="tr">' >> $STATUS_FILE
    echo "<td class='td' data-title='Common Name'>$(echo $client|awk -F',' '{print $2}')</td>" >> $STATUS_FILE
    echo "<td class='td' data-title='VPN Address'>$(echo $client|awk -F',' '{print $1}')</td>" >> $STATUS_FILE
    echo "<td class='td' data-title='Remote Address'>$(echo $client|awk -F',' '{print $3}')</td>" >> $STATUS_FILE
    echo "<td class='td' data-title='Last Refresh'>$(echo $client|awk -F',' '{print $4}')</td>" >> $STATUS_FILE
    echo '</tr>' >> $STATUS_FILE
done

