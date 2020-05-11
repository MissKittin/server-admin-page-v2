#!/bin/dash
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:/usr/local/sbin

case $1 in
	### index.php -> home.php -> login.php -> login-form.php
	'check-internet')
		ip=`wget -q -O- http://ipinfo.io/ip`
		[ "$2" = 'on-dashboard' ] && no_newline='-n'
		if echo -n "$ip" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' > /dev/null 2>&1; then
			case $2 in
				'on-dashboard')
					echo "Internet connection: yes, public IP: ${ip}<br>"
				;;
				*)
					echo 'Internet connection: yes<br>'
					echo "Public IP: $ip"
				;;
			esac
		else
			echo $no_newline 'Internet connection: no'
			[ "$2" = 'on-dashboard' ] && echo '<br>'
		fi
	;;
	### home.php
	'dashboard-info')
		############### WIRED ETHERNET AND WIRELESS PPP SUPPORT ONLY
		#Gateway <interface name> <interface ip>
		#Internet connection: <yes || no>, outside IP: <outside ip>
		#<if wireless>Range: <img sonyericsson range icon>
		#<if wireless> SMS service available: yes
		#Received <rx value>MB, transmitted <tx value>GB
		#<if wireless has limits> Data used: <percentage value>% <used value>GB/<limit value>GB <bar>
		###############

		# printers
		print_S6()
		{
			echo -n "$6"
		}
		print_rx()
		{
			[ "${27}${28}" = '0overruns' ] && \
				echo -n "${21}${22}" | tr -d '(' | tr -d ')' || \
				echo -n "${27}${28}" | tr -d '(' | tr -d ')'
		}
		print_tx()
		{
			[ "${43}${44}" = '0overruns' ] && \
				echo -n "${37}${38}" | tr -d '(' | tr -d ')' || \
				echo -n "${43}${44}" | tr -d '(' | tr -d ')'
		}

		# wireless & ppp
		default_gw_wireless()
		{
			echo "$default_gw" | grep '^wlan' > /dev/null 2>&1 && return 0
			echo "$default_gw" | grep '^ppp' > /dev/null 2>&1 && return 0
			return 1
		}
		wireless_range()
		{
			echo -n 'Not implemented'
		}
		sms_service_available()
		{
			echo -n 'Not implemented'
		}
		check_wireless_limits()
		{
			echo -n 'Not implemented'
		}

		# stats
		rx_tx_count()
		{
			echo -n 'Received: '
			print_rx $default_gw_ifconfig
			echo -n ', transmitted: '
			print_tx $default_gw_ifconfig
			echo ''
		}

		# main
		echo -n 'System started '; uptime -s; echo '<br>'
		echo -n 'Uptime: '; uptime -p | sed 's/up //g'; echo '<br>'
		[ "`sensors | grep fan1 | awk '{print $2}'`" = 0 ] && echo 'CPU fan: stopped<br><br>' || echo 'CPU fan: running<br><br>'
		default_gw=`route | grep default | awk '{print $8}'`; if [ "$default_gw" = '' ]; then
			echo '<h3>No default gateway</h3>'
		else
			default_gw_ifconfig=`ifconfig $default_gw`; default_gw_ip=`print_S6 $default_gw_ifconfig`; echo "Default gateway: ${default_gw} ${default_gw_ip}<br>"
			default_gw_wireless || \
				if ethtool $default_gw | grep 'Link detected: yes' > /dev/null 2>&1; then
					echo 'Link detected: yes<br>'
				fi
			$0 check-internet on-dashboard;
			default_gw_wireless && echo "<br>Range: `wireless_range`<br>" 
			default_gw_wireless && echo "SMS service available: `sms_service_available`<br>"
			rx_tx_count
			default_gw_wireless && check_wireless_limits
		fi
	;;
	### notifications.php
	'get-notifications')
		notify-daemon.sh journal list www
	;;
	'remove-notify')
		notify-daemon.sh journal del $2
	;;
	### net-ifaces.php
	'interfaces')
		SETTINGS=`firewall.sh where-are-you`
		. $SETTINGS/networks.rc
		case $2 in
			'wan')
				IFACE=$WAN
			;;
			'lan')
				IFACE=$LAN
			;;
			'ppp')
				IFACE=$PPP
			;;
			'1gbps')
				IFACE=$G1
			;;
			'100mbps')
				IFACE=$M100
			;;
			'wifi')
				eval `cat /etc/hostapd/hostapd.conf | grep interface=. | grep -v ctrl`
				IFACE=$interface
			;;
			'wifi-in')
				eval `cat /etc/wicd/manager-settings.conf | grep 'wireless_interface = ' | tr -d ' '`
				IFACE=$wireless_interface
			;;
		esac
		if [ "$3" = 'print' ]; then
			echo -n "$IFACE"
		else
			[ "`ifconfig $IFACE`" = '' ] && echo -n '<span style="color: #ff0000;">Not connected</span>' && exit 0
			ifconfig $IFACE
		fi
	;;
	'interfaces-all')
		ifconfig -a
	;;
	'vpn_info')
		iface_pptp='pptp'
		iface_l2tp='l2tp'
		print_S1()
		{
			echo $1 | tr -d ':'
		}
		case $2 in
			'pptp')
				ifconfig | grep "$iface_pptp" > /dev/null 2>&1 || echo -n 'Inactive'
				ifconfig | grep "$iface_pptp" | while read line; do
					ifconfig `print_S1 $line`
				done
			;;
			'l2tp')
				ifconfig | grep "$iface_l2tp" > /dev/null 2>&1 || echo -n 'Inactive'
				ifconfig | grep "$iface_l2tp" | while read line; do
					ifconfig `print_S1 $line`
				done
			;;
		esac
	;;
	### net-bwusage.php
	'bwusage')
		name="$3"

		print_S2()
		{
			echo -n "$2"
		}
		parse_mb()
		{
			in_kb=${6%.*}
			out_kb=${7%.*}
			in_mb=$((in_kb/1024))
			out_mb=$((out_kb/1024))
			echo -n "<td>$name</td>"
			echo -n '<td><div class="bar-out"><div class="bar" style="width: '"$in_mb"'px; background-color: #777777;"></div></div></td>'
			echo -n '<td><div class="bar-out"><div class="bar" style="width: '"$out_mb"'px; background-color: #777777;"></div></div></td>'
		}
		parse_gb()
		{
			in_kb=${6%.*}
			out_kb=${7%.*}
			in_mb=$((in_kb/1024))
			out_mb=$((out_kb/1024))
			in_percent=$((in_mb/10))
			out_percent=$((out_mb/10))
			echo -n "<td>$name</td>"
			echo -n '<td><div class="bar-out"><div class="bar" style="width: '"$in_percent"'px; background-color: #777777;"></div></div></td>'
			echo -n '<td><div class="bar-out"><div class="bar" style="width: '"$out_percent"'px; background-color: #777777;"></div></div></td>'
		}
		parse_wifi()
		{
			in_kb=${6%.*}
			out_kb=${7%.*}
			in_mb=$((in_kb/1024))
			out_mb=$((out_kb/1024))
			# Check wifi mode
			eval `cat /etc/hostapd/hostapd.conf | grep hw_mode=.`
			case $hw_mode in
				'b')
					in_mb_100="${in_mb}00"
					out_mb_100="${out_mb}00"
					in_percent=$((in_mb_100/11))
					out_percent=$((out_mb_100/11))
				;;
				'g')
					in_mb_100="${in_mb}00"
					out_mb_100="${out_mb}00"
					in_percent=$((in_mb_100/54))
					out_percent=$((out_mb_100/54))
				;;
				'n')
					in_percent=$((in_mb/6))
					out_percent=$((out_mb/6))
				;;
			esac
			echo -n "<td>$name</td>"
			echo -n '<td><div class="bar-out"><div class="bar" style="width: '"$in_percent"'px; background-color: #777777;"></div></div></td>'
			echo -n '<td><div class="bar-out"><div class="bar" style="width: '"$out_percent"'px; background-color: #777777;"></div></div></td>'
		}

		case $2 in
			'eth')
				interface=`$0 interfaces wan print`
				speed_value=`ethtool $interface | grep 'Speed:'`
				speed=`print_S2 $speed_value`
				case $speed in
					'100Mb/s')
						parse_mb `ifstat -i $interface -b 0.1 1`
					;;
					'1000Mb/s')
						parse_gb `ifstat -i $interface -b 0.1 1`
					;;
				esac
			;;
			'1gbps')
				interface=`$0 interfaces 1gbps print`
				speed_value=`ethtool $interface | grep 'Speed:'`
				speed=`print_S2 $speed_value`
				case $speed in
					'100Mb/s')
						parse_mb `ifstat -i $interface -b 0.1 1`
					;;
					'1000Mb/s')
						parse_gb `ifstat -i $interface -b 0.1 1`
					;;
				esac
			;;
			'100mbps')
				interface=`$0 interfaces 100mbps print`
				parse_mb `ifstat -i $interface -b 0.1 1`
			;;
			'wifi')
				interface=`$0 interfaces wifi print`
				parse_wifi `ifstat -i $interface -b 0.1 1`
			;;
			'wifi-in')
				interface=`$0 interfaces wifi-in print`
				if [ "`ifconfig $interface`" = '' ]; then
					echo -n "<td>$name</td>"
					echo -n '<td><div class="bar-out"><div class="bar" style="width: 100px; background-color: #000000;"></div></div></td>'
					echo -n '<td><div class="bar-out"><div class="bar" style="width: 100px; background-color: #000000;"></div></div></td>'

				else
					parse_wifi `ifstat -i $interface -b 0.1 1`
				fi
			;;
		esac
	;;
	### net-routing.php
	'net-routing-list')
		case $2 in
			'route')
				route
			;;
			'brctl')
				print_details()
				{
					brctl showstp $1
				}
				INDICATOR=0
				brctl show | grep 'br' | while read line; do
					if [ "$INDICATOR" = 0 ]; then
						INDICATOR=$((INDICATOR+1))
					else
						print_details $line
					fi
				done
			;;
			'bonds')
				echo '<span style="color: #ff0000;">Not implemented!</span>'
			;;
			'iptables')
				iptables --list
			;;
			'arp')
				arp
			;;
		esac
	;;
	'list-iptables-settings')
		SETTINGS=`firewall.sh where-are-you`
		. $SETTINGS/networks.rc

		parse_firewall_line()
		{
			[ "$1" = '' ] && return
			[ "$1" = '#' ] && return
			[ "${1%${1#?}}"x = '#x' ] && return

			if [ "$2" = '-A' ]; then
				# Firewall
				if [ "$3" = 'INPUT' ]; then
					eval echo -n "'->' $5"
					if [ "$5" = 'state' ]; then
						echo " $7 $9"
					elif [ "$8" = '-j' ]; then
						echo " protocol ${7} ${9}"
					else
						echo " ${9}/${7} ${11}"
					fi
				fi
				if [ "$3" = 'OUTPUT' ]; then
					echo -n '<-'
					if [ "$6" = '-j' ]; then
						echo " protocol ${5} ${7}"
					else
						echo " ${5}/${7} ${9}"
					fi
				fi
				# Routing
				if [ "$3" = 'FORWARD' ]; then
					if [ "$9" = 'state' ]; then
						eval echo "${5} '-->' ${7} ${11} ${13}"
					else
						eval echo "${5} '-->' ${7} ${9}"
					fi
				fi
			fi

			if [ "$2" = '-P' ]; then
				echo "Policy $3 $4"
			fi

			# Routing
			if [ "$3" = 'nat' ]; then
				eval echo "NAT $7"
			fi
		}
		parse_forwarding_line()
		{
			# Special function only for forwarding
			[ "$1" = '' ] && return
			[ "$1" = '#' ] && return
			[ "${1%${1#?}}"x = '#x' ] && return

			if [ "$2" = '-A' ]; then
				if [ "$3" = 'FORWARD' ]; then
					
					if [ "$4" = '-i' ] && [ "$6" = '-o' ]; then
						eval echo "${5} '-->' ${7} ${9}"
					else
						if [ "$9" = 'state' ]; then
							eval echo "${5} '-->' ${7} ${11} ${13}"
						else
							eval echo "'-->' ${7} ${9}/${5}"
						fi
					fi
				fi
			fi

			if [ "$2" = '-P' ]; then
				echo "Policy $3 $4"
			fi

			if [ "$3" = 'nat' ]; then
				eval echo -n "$7"
				echo -n ' '
			fi
		}

		case $2 in
			'firewall')
				echo 'Firewall settings:'
				cat $SETTINGS/firewall.rc | while read line; do
					parse_firewall_line $line
				done
			;;
			'routing')
				echo; echo 'Forwarding settings:'
				cat $SETTINGS/forwarding.rc | while read line; do
					parse_forwarding_line $line
				done
				echo; echo 'Routing settings:'
				cat $SETTINGS/routing.rc | while read line; do
					parse_firewall_line $line
				done
			;;
			'forwarding')
				cat $SETTINGS/forwarding.rc | while read line; do
					parse_forwarding_line $line
				done
			;;
		esac
	;;
	### net-forwarding.php
	'generate-interfaces')
		for i in wan wifi-in ppp lan; do
			interface=`$0 interfaces $i print`
			echo '<option value="'"$interface"'">'"$interface"'</option>'
		done
	;;
	'forward')
		case $2 in
			'add')
				# $3 - port, $4 - protocol, $5 - input port, $6 - destination ip, $7 - output port

				SETTINGS=`firewall.sh where-are-you`
				input_iface=`cat $SETTINGS/networks.rc | grep "$5"`
				input_type=${input_iface%=*}
				output_iface=`cat $SETTINGS/networks.rc | grep "$7"`
				output_type=${output_iface%=*}

				[ "$5" = "$7" ] && exit 1 # if eg eth0==eth0, not necessary

				[ "$3" = '' ] && exit 1
				[ "$4" = '' ] && exit 1
				[ "$5" = '' ] && exit 1
				[ "$6" = '' ] && exit 1
				[ "$7" = '' ] && exit 1

				if [ "$4" = 'tcpudp' ]; then
					# Write to config file
					echo '' >> $SETTINGS/forwarding.rc
					echo '$iptables -t nat -A PREROUTING -i $'"$input_type"' -p tcp --dport '"$3"' -j DNAT --to-destination '"$6" >> $SETTINGS/forwarding.rc
					echo '$iptables -A FORWARD -p tcp -o $'"$output_type"' -d '"$6"' --dport '"$3"' -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT' >> $SETTINGS/forwarding.rc
					echo '$iptables -t nat -A PREROUTING -i $'"$input_type"' -p udp --dport '"$3"' -j DNAT --to-destination '"$6" >> $SETTINGS/forwarding.rc
					echo '$iptables -A FORWARD -p udp -o $'"$output_type"' -d '"$6"' --dport '"$3"' -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT' >> $SETTINGS/forwarding.rc

					# Apply
					iptables -t nat -A PREROUTING -i $5 -p tcp --dport $3 -j DNAT --to-destination $6
					iptables -A FORWARD -p tcp -o $7 -d $6 --dport $3 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
					iptables -t nat -A PREROUTING -i $5 -p udp --dport $3 -j DNAT --to-destination $6
					iptables -A FORWARD -p udp -o $7 -d $6 --dport $3 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
				else
					# Write to config file
					echo '' >> $SETTINGS/forwarding.rc
					echo '$iptables -t nat -A PREROUTING -i $'"$input_type"' -p '"$4"' --dport '"$3"' -j DNAT --to-destination '"$6" >> $SETTINGS/forwarding.rc
					echo '$iptables -A FORWARD -p '"$4"' -o $'"$output_type"' -d '"$6"' --dport '"$3"' --state NEW,RELATED,ESTABLISHED -j ACCEPT' >> $SETTINGS/forwarding.rc

					# Apply
					iptables -t nat -A PREROUTING -i $5 -p $4 --dport $3 -j DNAT --to-destination $6
					iptables -A FORWARD -p $4 -o $7 -d $6 --dport $3 --state NEW,RELATED,ESTABLISHED -j ACCEPT
				fi
			;;
		esac
	;;
	### net-devices.php
	'list-devices')
		IPs=''
		print_S1()
		{
			echo -n "$1"
		}
		print_S2()
		{
			echo -n "$2"
		}
		print_S6()
		{
			echo -n "$6"
		}
		parse_dhcpd_reservations()
		{
			cat /usr/local/etc/dhcp/reservations.conf | while read line; do
				[ "$1" = "`print_S2 $line`" ] && print_S6 $line | tr -d ';'
			done
		}
		buttons_reserve_ban()
		{
			host_ip=`echo -n "$1" | tr '.' '_'`

			[ "`$0 net-block check $1 $2`" = 'banned' ] && \
				ban_button='<td style="border: none;"><button name="unban" type="submit" value="'"$host_ip $2"'">Unban</button></td>' || \
				ban_button='<td style="border: none;"><button name="ban" type="submit" value="'"$host_ip $2"'">Ban</button></td>'

			if echo -n "$2" | grep 'lan' > /dev/null 2>&1; then
				name=$2; ip=$1; mac=''
			else
				name=$3; ip=$1; mac=$2
			fi
			$0 net-reserve check $name $ip $mac && \
				reserve_button='<td style="border: none;"><button name="release" type="submit" value="'"$host_ip $2 $3"'" onclick="return confirm('"'"'Are you sure?'"'"');">Release</button></td>' || \
				reserve_button='<td style="border: none;"><button name="reserve" type="submit" value="'"$host_ip $2 $3"'">Reserve</button></td>'

			echo -n "${ban_button}${reserve_button}"
		}
		check_status()
		{
			# &#10004; yes
			# &#10008; no
			echo -n '<span style="font-weight: bold;">?</span>'
		}
		parse_reserved()
		{
			[ "${1%${1#?}}"x = '#x' ] && return
			ip=`print_S1 $line`
			hostname=`print_S2 $line`
			#mac=`parse_arp $ip`
			mac=`parse_dhcpd_reservations $hostname`

			echo "<tr><td align="center">`check_status $ip`</td><td>$hostname</td><td>$ip</td><td>$mac</td><td align="center">&#10004;</td>`buttons_reserve_ban $ip $mac $hostname`</tr>"
		}
		check_reserved()
		{
			reserved=false
			cd /usr/local/etc/hosts.d
			for i in *; do
				content=`cat $i`
				value=`print_S1 $content`
				[ "$value" = "$1" ] && reserved=true && break
			done
			$reserved && echo -n '&#10004;' || echo -n '&#10008;'
		}
		parse_dhcpd()
		{
			# if ! no mac
			[ "$2" = '' ] || \
			case $3 in
				'')
					# IP MAC
					reserved=`check_reserved $1`
					if ! echo $IPs | grep $1 > /dev/null 2>&1; then
						echo "<tr><td align="center">`check_status $1`</td><td><!-- hostname --></td><td>$1</td><td>$2</td><td align="center">$reserved</td>`buttons_reserve_ban $1 $2`</tr>"
						IPs="$IPs $1"
					fi
				;;
				*)
					# Hostname IP MAC
					reserved=`check_reserved $2`
					NAME=`echo -n "$1" | tr -d '"'`
					if ! echo $IPs | grep $2 > /dev/null 2>&1; then
						echo "<tr><td align="center">`check_status $2`</td><td>$NAME</td><td>$2</td><td>$3</td><td align="center">$reserved</td>`buttons_reserve_ban $2 $3 $NAME`</tr>"
						IPs="$IPs $2"
					fi
				;;
			esac
		}

		# add reserved
		cat /usr/local/etc/hosts.d/reservations | while read line; do
			parse_reserved $line
		done

		# parse dhcpd.leases
		awk 'BEGIN{
			while( (getline line < "maclist") > 0){
				mac[line]
			}
			RS="}"
			FS="\n"
		}
		/lease/{
			for(i=1;i<=NF;i++){
				gsub(";","",$i)
				if ($i ~ /lease/) {
					m=split($i, IP," ")
					ip=IP[2]
				}
				if( $i ~ /hardware/ ){
					m=split($i, hw," ")
					ether=hw[3]
				}
				if ( $i ~ /client-hostname/){
					m=split($i,ch, " ")
					hostname=ch[2]
				}
			}
			print hostname " "ip " "ether
		} ' /var/lib/dhcp/dhcpd.leases | while read line; do
			parse_dhcpd $line
		done
	;;
	'net-reserve')
		tab=$'\t'
		case $2 in
			'add')
				echo "reserve add $3"
				echo "<br>IP: $4, MAC: $5"

				echo -n "$3" | grep '.lan' > /dev/null 2>&1 && hostname="$3" || hostname="${3}.lan"

				cat /usr/local/etc/dhcp/reservations.conf | grep "host $hostname { hardware ethernet $5; fixed-address $4; }" > /dev/null 2>&1 && exit 1
				cat /usr/local/etc/hosts.d/reservations | grep "${4}${tab}${hostname}" > /dev/null 2>&1 && exit 1

				echo "host $hostname { hardware ethernet $5; fixed-address $4; }" >> /usr/local/etc/dhcp/reservations.conf
				echo -e "${4}\t${hostname}" >> /usr/local/etc/hosts.d/reservations

				generate-dns-hosts.sh
			;;
			'del')
				[ "$3" = '' ] && exit 1
				[ "$4" = '' ] && exit 1
				[ "$5" = '' ] && exit 1

				sed -i '/host '"$3"' { hardware ethernet '"$5"'; fixed-address '"$4"'; }/d' /usr/local/etc/dhcp/reservations.conf
				sed -i '/'"$4"'	'"$3"'/d' /usr/local/etc/hosts.d/reservations
			;;
			'check')
				RESERVED=false

				if [ "$5" = '' ]; then
					cat /usr/local/etc/dhcp/reservations.conf | grep "host $3 { " | grep "fixed-address $4; }" > /dev/null 2>&1 && RESERVED=true
				else
					cat /usr/local/etc/dhcp/reservations.conf | grep "host $3 { hardware ethernet $5; fixed-address $4; }" > /dev/null 2>&1 && RESERVED=true
				fi
				cat /usr/local/etc/hosts.d/reservations | grep "${4}${tab}${3}" > /dev/null 2>&1 && RESERVED=true

				$RESERVED && exit 0 || exit 1
			;;
			'details')
				echo '<h3>DHCP</h3><pre>'
				cat /usr/local/etc/dhcp/reservations.conf
				echo '</pre><h3>DNS</h3><pre>'
				cat /usr/local/etc/hosts.d/reservations
				echo '</pre><h3>DDNS</h3><pre>'
				cat /tmp/.ddns-hosts
				echo '</pre><h3>ARP</h3><pre>'
				$0 list-arp
				echo '</pre><h3>DHCP leases</h3><pre>'
				cat /var/lib/dhcp/dhcpd.leases
				echo '</pre><br>'
			;;
		esac
	;;
	'net-block')
		[ "$3" = '' ] && exit 1 # if no ip
		[ "$4" = '' ] && exit 1	# if no mac

		method_by='mac' # ip or mac
		case $2 in
			'ban')
				case $method_by in
					'ip')
						iptables -I INPUT -s $3 -j REJECT
						iptables -I OUTPUT -s $3 -j REJECT
						iptables -I FORWARD -s $3 -j REJECT
					;;
					'mac')
						iptables -I INPUT -m mac --mac-source $4 -j REJECT
						iptables -I FORWARD -m mac --mac-source $4 -j REJECT
					;;
				esac
			;;
			'unban')
				case $method_by in
					'ip')
						iptables -D INPUT -s $3 -j REJECT
						iptables -D OUTPUT -s $3 -j REJECT
						iptables -D FORWARD -s $3 -j REJECT
					;;
					'mac')
						iptables -D INPUT -m mac --mac-source $4 -j REJECT
						iptables -D FORWARD -m mac --mac-source $4 -j REJECT
					;;
				esac
			;;
			'check')
				case $method_by in
					'ip')
						iptables --list | grep "$3" | grep 'REJECT' > /dev/null 2>&1 && \
							echo -n 'banned' || \
							echo -n 'free'
					;;
					'mac')
						iptables --list | grep -i "$4" | grep 'REJECT' > /dev/null 2>&1 && \
							echo -n 'banned' || \
							echo -n 'free'
					;;
				esac
			;;
		esac
	;;
	### net-wifi.php
	'wifi')
		case $2 in
			'list-aps')
				print_S2()
				{
					echo -n "$2"
				}

				# AP config
				print_S12()
				{
					echo -n "${12}" | tr '[:lower:]' '[:upper:]'
				}
				ap_ifconfig=`$0 interfaces wifi`
				ap_mac=`print_S12 $ap_ifconfig`

				# Parser
				buttons_add_connect()
				{
					if cat /etc/wicd/wireless-settings.conf | grep "$2" > /dev/null 2>&1; then
						echo -n '<td><button name="connect" type="submit" value="'"$1"'">Connect</button></td>'
					else
						echo '<td><button name="add" type="submit" value="'"$1"'">Add</button></td><td><input type="password" name="password"></td>'
					fi
				}
				list_range()
				{
					value=`wicd-cli --wireless --network $1 --network-details  | grep 'Quality: '`
					range=`print_S2 $value`

					if [ "$range" -le '50' ]; then
						echo -n '<img src="/range_icons/range_0.png" alt="range">'
					elif [ "$range" -le '60' ]; then
						echo -n '<img src="/range_icons/range_1.png" alt="range">'
					elif [ "$range" -le '70' ]; then
						echo -n '<img src="/range_icons/range_2.png" alt="range">'
					elif [ "$range" -le '80' ]; then
						echo -n '<img src="/range_icons/range_3.png" alt="range">'
					elif [ "$range" -le '90' ]; then
						echo -n '<img src="/range_icons/range_4.png" alt="range">'
					elif [ "$range" -gt '90' ]; then
						echo -n '<img src="/range_icons/range_5.png" alt="range">'
					fi
				}
				parse_list_networks()
				{
					[ "$1" = '#' ] && return
					[ "$2" = "$ap_mac" ] && return
					[ "$4" = '<hidden>' ] && name="(hidden)" || name="$4"
					rm /tmp/.web_shell_no_wifi_networks

					echo "<tr><td>$name</td><td>$2</td><td>$3</td><td>`list_range $1`</td>`buttons_add_connect $1 $2`</tr>"
				}

				# Check if wifi card connected
				eval `cat /etc/wicd/manager-settings.conf | grep 'wireless_interface = ' | tr -d ' '`
				if ! ifconfig -a | grep "$wireless_interface" > /dev/null 2>&1; then
					echo '<tr><td colspan="4"><span style="color: #aa0000;">WiFi card not connected</span></td></tr>'
					exit 0
				fi

				# DO!
				touch /tmp/.web_shell_no_wifi_networks
				wicd-cli --wireless --scan --list-networks | while read line; do
					case $line in
						'Error: Could not connect to the daemon. Please make sure it is running.')
							echo '<tr><td colspan="4"><span style="color: #aa0000;">wicd daemon not running</span></td></tr>'
							echo '<tr><td colspan="4"><span style="color: #aa0000;">enable it <a href="sys-daemons.php">here</a></span></td></tr>'
							rm /tmp/.web_shell_no_wifi_networks
							break
						;;
					esac
					parse_list_networks $line
				done
				[ -e /tmp/.web_shell_no_wifi_networks ] && echo '<tr><td colspan="4">No networks available</td></tr>' && rm /tmp/.web_shell_no_wifi_networks
			;;
			'add')
				[ "$3" = '' ] && exit 1
				[ "$4" = '' ] && exit 1

				wicd-cli --wireless --network $3 --network-property key --set-to $4
				wicd-cli --wireless --network $3 --connect
			;;
			'connect')
				[ "$3" = '' ] && exit 1
				wicd-cli --wireless --network $3 --connect
			;;
			'disconnect')
				wicd-cli --wireless --disconnect
			;;
			'print-connected')
				# Check if wifi card connected
				eval `cat /etc/wicd/manager-settings.conf | grep 'wireless_interface = ' | tr -d ' '`
				if ! ifconfig -a | grep "$wireless_interface" > /dev/null 2>&1; then
					exit 1
				fi

				# Check if wicd running
				/etc/init.d/wicd status > /dev/null 2>&1 || exit 1

				# must wait
				sleep 1

				eval `cat /etc/wicd/manager-settings.conf | grep 'wireless_interface = ' | tr -d ' '`
				print_S4()
				{
					echo -n "$4"
				}
				wifi_iwconfig=`iwconfig $wireless_interface`
				connected_essid_value=`print_S4 $wifi_iwconfig | tr -d '"'`
				connected_essid=${connected_essid_value#*:}

				[ "$connected_essid" = 'off/any' ] && message='Not connected' || message="Connected to $connected_essid"
				echo -n "$message"
			;;
		esac
	;;
	### net-ap.php
	'ap')
		case $2 in
			'get')
				case $3 in
					'ssid')
						eval `cat /etc/hostapd/hostapd.conf | grep ssid=.`
						echo -n "$ssid"
					;;
					'hide-ssid')
						eval `cat /etc/hostapd/hostapd.conf | grep ignore_broadcast_ssid=.`
						[ "$ignore_broadcast_ssid" = '1' ] && echo -n 'checked="checked"'
					;;
					'mode')
						eval `cat /etc/hostapd/hostapd.conf | grep hw_mode=.`
						for i in b g n; do
							[ "$hw_mode" = "$i" ] && echo "<option selected>$i</option>" || echo "<option>$i</option>"
						done
					;;
					'channel')
						eval `cat /etc/hostapd/hostapd.conf | grep channel=.`
						for i in 0 11 12 13 14; do
							if [ "$i" = '0' ]; then
								[ "$channel" = '0' ] && echo "<option selected>auto</option>" || echo "<option>auto</option>"
							else
								[ "$channel" = "$i" ] && echo "<option selected>$i</option>" || echo "<option>$i</option>"
							fi
						done
					;;
				esac
			;;
			'set')
				case $3 in
					'ssid')
						eval `cat /etc/hostapd/hostapd.conf | grep ssid=.`
						[ "$ssid" = "$4" ] && exit 0
						sed -i 's/ssid='"$ssid"'/ssid='"$4"'/g' /etc/hostapd/hostapd.conf
					;;
					'password')
						eval `cat /etc/hostapd/hostapd.conf | grep wpa_passphrase=.`
						[ "$wpa_passphrase" = "$4" ] && exit 0
						sed -i 's/wpa_passphrase='"$wpa_passphrase"'/wpa_passphrase='"$4"'/g' /etc/hostapd/hostapd.conf
					;;
					'hide-ssid')
						eval `cat /etc/hostapd/hostapd.conf | grep ignore_broadcast_ssid=.`
						[ "$4" = 'yes' ] && set_ignore_broadcast_ssid='1' || set_ignore_broadcast_ssid='0'
						[ "$ignore_broadcast_ssid" = "set_ignore_broadcast_ssid" ] && exit 0
						sed -i 's/ignore_broadcast_ssid='"$ignore_broadcast_ssid"'/ignore_broadcast_ssid='"$set_ignore_broadcast_ssid"'/g' /etc/hostapd/hostapd.conf
					;;
					'mode')
						eval `cat /etc/hostapd/hostapd.conf | grep hw_mode=.`
						[ "$hw_mode" = "$4" ] && exit 0
						sed -i 's/hw_mode='"$hw_mode"'/hw_mode='"$4"'/g' /etc/hostapd/hostapd.conf
					;;
					'channel')
						eval `cat /etc/hostapd/hostapd.conf | grep channel=.`
						[ "$4" = 'auto' ] && new_channel='0' || new_channel="$4"
						[ "$channel" = "$new_channel" ] && exit 0
						sed -i 's/channel='"$channel"'/channel='"$new_channel"'/g' /etc/hostapd/hostapd.conf
					;;
				esac
			;;
			'restart')
				/etc/init.d/hostapd restart
			;;
		esac
	;;
	### net-vpn.php
	'vpn')
		tab=$'\t'
		print_S1()
		{
			echo -n "$1"
		}
		print_S3()
		{
			echo -n "$3"
		}
		case $2 in
			'get')
				# Can get only login, no passwords
				case $3 in
					'pptp')
						string=`cat /etc/ppp/chap-secrets | grep 'pptpd'`
						print_S1 $string
					;;
					'l2tp')
						string=`cat /etc/ppp/chap-secrets | grep 'xl2tpd'`
						print_S1 $string
					;;
				esac
			;;
			'set')
				[ "$5" = '' ] && exit 0
				case $3 in
					'pptp')
						string=`cat /etc/ppp/chap-secrets | grep 'pptpd'`
						login=`print_S1 $string`
						password=`print_S3 $string`
						case $4 in
							'login')
								[ "$login" = "$5" ] && exit 0
								sed -i 's/'"$string"'/'"${5}${tab}"'pptpd'"${tab}${password}${tab}${tab}"'/g' /etc/ppp/chap-secrets
							;;
							'password')
								[ "$password" ="$5" ] && exit 0
								sed -i 's/'"$string"'/'"${login}${tab}"'pptpd'"${tab}${5}${tab}${tab}"'/g' /etc/ppp/chap-secrets
							;;
						esac
					;;
					'l2tp')
						string=`cat /etc/ppp/chap-secrets | grep 'xl2tpd'`
						login=`print_S1 $string`
						password=`print_S3 $string`
						server_password_string=`cat /usr/local/etc/racoon/psk.txt`
						server_password=`cat /usr/local/etc/racoon/psk.txt | awk '{print $2}'`
						case $4 in
							'login')
								[ "$login" = "$5" ] && exit 0
								sed -i 's/'"$string"'/'"${5}${tab}"'xl2tpd'"${tab}${password}${tab}${tab}"'/g' /etc/ppp/chap-secrets
							;;
							'password')
								[ "$password" = "$5" ] && exit 0
								sed -i 's/'"$string"'/'"${login}${tab}"'xl2tpd'"${tab}${5}${tab}${tab}"'/g' /etc/ppp/chap-secrets
							;;
							'serverpassword')
								[ "$server_password" = "$5" ] && exit 0
								sed -i 's/'"$server_password_string"'/* '"$5"'/g' /usr/local/etc/racoon/psk.txt
							;;
						esac
					;;
				esac
			;;
		esac
	;;
	### sys-logs.php
	'ethtool')
		for i in `ls /sys/class/net`; do
			/sbin/ethtool $i
			echo; echo;
		done
	;;
	### sys-sensors.php
	'sensors')
		sensors  | tail -n +8 | head -n -2
	;;
	### sys-updates.php
	'apt-update')
		apt-get update 2>&1
		echo '<a href="sys-updates.php">Reload</a>'
	;;
	'updates')
		apt-check -h -c -f 2>&1
	;;
	'system-eol')
		# Get it from notify-daemon
		home_dir=`notify-daemon.sh print-home-dir`
		. $home_dir/events.rc.d/eol.rc
		echo -n "$eol__timestamp"
	;;
	### sys-daemons.php
	'check_service')
		GREEN='<span style="color: #00aa00;">'
		RED='<span style="color: #ff0000;">'

		/etc/init.d/$2 status > /dev/null 2>&1 && \
			echo -n "${GREEN}Running</span>" || \
			echo -n "${RED}Stopped</span>"
	;;
	'check_special_service')
		GREEN='<span style="color: #00aa00;">'
		RED='<span style="color: #ff0000;">'

		if [ "$2" = 'xl2tpd' ]; then
			ps -A | grep xl2tpd > /dev/null 2>&1 && \
				echo -n "${GREEN}Running</span>" || \
				echo -n "${RED}Stopped</span>"
			exit 0
		fi

		get_reply()
		{
			$2 status > /dev/null 2>&1 && \
				echo -n "${GREEN}Running</span>" || \
				echo -n "${RED}Stopped</span>"
		}
		get_reply `whereis $2`
	;;
	'service')
		/etc/init.d/$2 $3 > /dev/null 2>&1
	;;
	'special_service')
		if [ "$2" = 'xl2tpd' ]; then
			/etc/init.d/xl2tpd $3
			exit 0
		fi

		print_S2()
		{
			echo -n "$2"
		}
		start_stop_service()
		{
			$1 $2 > /dev/null 2>&1
		}
		service_path=$(print_S2 `whereis $2`)
		start_stop_service $service_path $3
	;;
	### sys-users.php
	logged_users)
		fquery()
		{
			HOST=`echo $6 | sed -e 's/(/ /g' | sed -e 's/)/ /g'`
			[ $HOST ] || HOST="local terminal"
			echo "<tr>
				<td>$1</td><!-- user -->
				<td>$2</td><!-- term -->
				<td>$4 $3 $5</td><!-- date -->
				<td>$HOST</td><!-- ip -->
				<td>"'<button type="submit" name="kick_user" value="'"$2"'">Kick</button></td>
			</tr>'
		}
		if ! last | grep 'still logged in' > /dev/null 2>&1; then
			echo '<tr>
				<td>-</td>
				<td>-</td>
				<td>- - -</td>
				<td>-</td>
			</tr>'
		else
			who | while read line; do
				fquery $line
			done
		fi
	;;
	### sys-notifications.php
	'notify-daemon-settings')
		case $2 in
			'print')
				notify-daemon-state.sh www $3
			;;
			'status')
				exec $0 check_special_service notify-daemon.sh
			;;
			'set')
				home_dir=`notify-daemon.sh print-home-dir`
				case $3 in
					'enable')
						case $4 in
							'event')
								cd $home_dir/events.rc.d
								mv $5 ${5%.disabled*}
							;;
							'critical-event')
								cd $home_dir/critical-events.rc.d
								mv $5 ${5%.disabled*}
							;;
							'sender-config')
								. $home_dir/sender_config.rc.d/$5
								name_search=`set | grep '__enabled='`
								name="\$${name_search%__*}__enabled"
								value=`eval echo -n "$name"`

								[ "$value" = 'true' ] && exit 0
								name=`echo -n "$name" | sed 's/\\$//g'`
								sed -i 's/'"$name"'='"'"'false'"'"'/'"$name"'='"'"'true'"'"'/g' $home_dir/sender_config.rc.d/$5
							;;
							'sender-manually')
								cd $home_dir/sender.rc.d
								mv $5 ${5%.disabled*}
							;;
						esac
					;;
					'disable')
						case $4 in
							'event')
								cd $home_dir/events.rc.d
								mv $5 ${5}.disabled
							;;
							'critical-event')
								cd $home_dir/critical-events.rc.d
								mv $5 ${5}.disabled
							;;
							'sender-manually')
								cd $home_dir/sender.rc.d
								mv $5 ${5}.disabled
							;;
						esac
					;;
				esac
			;;
		esac
	;;
	### storage.php
	'disk_usage')
		CGREEN='00aa00'
		CRED='ff0000'
		CYELLOW='cccc00'

		fquery()
		{
			### function parameters: fquery_nodev=false|true

			# Edit parameters
			case $6 in
				'/')
					MOUNTPOINT=' root'
					DEVICE='sda1'
				;;
				*)
					MOUNTPOINT=`echo $6 | sed -e 's\/media/\ \g'`
					DEVICE=`echo $1 | sed -e 's\/dev/\ \g'`
				;;
			esac
			BAR_PERCENT=`echo $5 | sed -e 's/%/px/g'`
			# Color bars
			BAR_COLOR=$CGREEN
			[ "`echo $5 | sed -e 's/%/ /g'`" -ge 70 ] && \
				BAR_COLOR=$CYELLOW
			[ "`echo $5 | sed -e 's/%/ /g'`" -ge 95 ] && \
				BAR_COLOR=$CRED
			# Create bar
			BAR='<div class="bar-out">
				<div class="bar" style="width: '"$BAR_PERCENT"'; background-color: #'"$BAR_COLOR"';">
				</div>
			</div>'
			# Make table row
			echo "<tr>
				<td>$MOUNTPOINT</td>
				<td>$2</td><!-- size -->
				<td>$3</td><!-- used -->
				<td>$4</td><!-- avail -->
				"; [ $fquery_nodev ] || echo "<td>$DEVICE</td>"; echo "
				<td>$BAR</td>
				<td style='text-align: right'>$5</td><!-- used -->
			</tr>"
		}

		case $2 in
			'') # normal
				# root
				df -h / | tail -n +2 | while read line; do
					fquery $line
				done
		
				# storage
				df -h | grep media | sort -k2 | while read line; do
					fquery $line
				done
			;;
			*) # custom
				[ "$3" = 'nodev' ] && fquery_nodev=true # setup fquery
				df -h | grep $2 | sort -k2 | while read line; do
					fquery $line
				done
			;;
		esac
	;;
	'ram_usage')
		fquery()
		{
			case $1 in
				'-/+') # Buff
					echo "<tr>
						<td>Buff: </td>
						<td>$3</td><!-- used -->
						<td>$4</td><!-- total -->
						<!-- --><td></td><td></td><td></td><!-- -->
						<td>`$0 ram_usage_bars $1`</td>
					</tr>"
				;;
				'Swap:') # Swap
					[ "$2" = "0B" ] || \
					echo "<tr>
						<td>$1 </td><!-- Swap: -->
						<td>$3</td><!-- used -->
						<td>$2</td><!-- total -->
						<!-- --><td></td><td></td><td></td><!-- -->
						<td>`$0 ram_usage_bars $1`</td>
					</tr>"
				;;
				*) # Mem
					echo "<tr>
						<td>$1 </td><!-- Mem: -->
						<td id=\"ram-usage\">$3</td><!-- used -->
						<td>$2</td><!-- total -->
						<td>$5</td><!-- shr -->
						<td>$6</td><!-- buff -->
						<td style=\"color: #8F00FF;\">$7</td><!-- cchd -->
						<td>`$0 ram_usage_bars $1`</td>
					</tr>"
				;;
			esac
		}
		free -h | tail -n +2 | while read line; do
			fquery $line
		done
	;;
	'ram_usage_bars')
		CGREEN='00aa00'
		CRED='ff0000'
		CYELLOW='888800'

		fquery()
		{
			## $1(Mem:) $2(1031716) $3(487920) $4(543796) $5(0) $6(13084)
			# Parameters
			[ "$1" = '-/+' ] && \
				BAR_PERCENT=$((($3*100)/($4+$3))) || \
				BAR_PERCENT=$((($3*100)/$2))
			[ "$1" = '-/+' ] || \
				BAR_CACHED=$((($7*100)/$2))
			# Color bars
			BAR_COLOR=$CGREEN
			[ "$BAR_PERCENT" -ge 60 ] && \
				BAR_COLOR=$CYELLOW || \
			[ "$BAR_PERCENT" -ge 80 ] && \
				BAR_COLOR=$CRED
			# Create bar
			BAR='<div class="bar-out" style="margin-bottom: 1px;">
				<div id="ram-bar-usage" class="bar" style="width: '"$BAR_PERCENT"'px; background-color: #'"$BAR_COLOR"';"></div><!-- used -->
			</div>
			<div class="bar-out">
				<div id="ram-bar-cached" class="bar" style="width: '"$BAR_CACHED"'px; background-color: #8F00FF;"></div><!-- cached -->
			</div>'

			# Print
			echo "$BAR"
		}
		free | grep -e $2 | while read line; do
			fquery $line
		done
	;;
	### power.php
	'suspend')
		sleep 5
		nohup acpid-suspend.sh > /dev/null 2>&1 &
	;;
	### power-autowakeup.php
	'autowakeup')
		acpid_suspend_sh_path=`whereis acpid-suspend.sh | awk '{print $2}'`
		case $2 in
			'get-enabled')
				eval `cat $acpid_suspend_sh_path | grep wakeup_enabled='.'`
				$wakeup_enabled && echo -n 'checked="checked"'
			;;
			'get-time')
				eval `cat $acpid_suspend_sh_path | grep wakeup_at='.'`
				eval `cat $acpid_suspend_sh_path | grep wakeup_enabled='.'`
				if $wakeup_enabled; then
					[ "$3" = 'only-time' ] && echo -n "$wakeup_at" || echo -n "Router will wake up at $wakeup_at after manual suspend"
				else
					[ "$3" = 'only-time' ] && echo -n "$wakeup_at"
				fi
			;;
			'set-enabled')
				eval `cat $acpid_suspend_sh_path | grep wakeup_enabled='.'`
				[ "$3" = 'yes' ] && wakeup_setting='true' || wakeup_setting='false'
				[ "$wakeup_enabled" = "$wakeup_setting" ] && exit 0
				sed -i 's/wakeup_enabled='"'""$wakeup_enabled""'"'/wakeup_enabled='"'"$wakeup_setting"'"'/g' $acpid_suspend_sh_path
			;;
			'set-time')
				eval `cat $acpid_suspend_sh_path | grep wakeup_at='.'`
				[ "$wakeup_at" = "$3" ] && exit 0
				sed -i 's/wakeup_at='"'""$wakeup_at""'"'/wakeup_at='"'"$3"'"'/g' $acpid_suspend_sh_path
			;;
		esac
	;;
esac

exit 0