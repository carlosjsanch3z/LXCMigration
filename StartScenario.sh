#!/bin/bash

ip=''
status=''
container='contenedor1'
lvname='additional'
apachedir='/var/www/html'
#functions

# Check State of the Container
function GetStatus() {
  status=$(lxc-info -n $container | grep 'State' | tr -s " " | cut -d " " -f 2)
}

# Attach LV
function Attachvol() {
  lxc-device -n $container add /dev/lvm-group/${lvname}
  lxc-attach -n $container -- mount /dev/lvm-group/${lvname} ${apachedir}
  lxc-attach -n $container -- systemctl restart apache2
}

# Get Current IP LXC Container
function GetIP() {
  ip=$(lxc-info -n $1 | grep 'IP' | tr -s " " | cut -d " " -f 2)
}

function SetDNAT() {
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $ip
}

function EnableForwarding() {
  sysctl -w net.ipv4.ip_forward=1
}

# Start
function StartScenario() {
  EnableForwarding
  GetStatus
  if [[ "$status" == "STOPPED" ]]; then
    lxc-start -n $container
    echo "DHCLIENT ..."
    sleep 4
  fi
  GetIP $container
  Attachvol
  SetDNAT
}

StartScenario
