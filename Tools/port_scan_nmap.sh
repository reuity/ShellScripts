#!/usr/bin/sh
CheckIPAddr() {
    IPADDR=$1
    if echo $IPADDR | grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" >/dev/null; then
        a=$(echo $IPADDR | awk -F . '{print $1}')
        b=$(echo $IPADDR | awk -F . '{print $2}')
        c=$(echo $IPADDR | awk -F . '{print $3}')
        d=$(echo $IPADDR | awk -F . '{print $4}')

        for num in $a $b $c $d; do
            if [ $num -gt 255 ] || [ $num -lt 0 ]; then
                echo "IP $IPADDR not available!"
                return 1
            fi
        done
        return 0
    else
        echo "$IPADDR not available!"
        return 1
    fi
}

iplist=$1
outfile=portscan$(date +%F-%T).txt

for ip in $(cat $iplist); do
    CheckIPAddr $ip &>/dev/null
    if [ $? = 0 ]; then
        nmap -p 80-32767 $ip | head -n -3 | tail -n +7 | awk '{ print "'$ip'",$0}' >>$outfile
    fi
done
