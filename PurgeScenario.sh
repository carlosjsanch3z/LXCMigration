#!/bin/bash

containers=(contenedor1 contenedor2)

# Operation Containers
function HandleContainers() {
  case "$2" in
      start) lxc-start -n $1 2> /dev/null
      echo "Raising $1"
      ;;
      stop) lxc-stop -n $1 -k 2> /dev/null
      echo "Stopping $1"
      ;;
  esac
}
# Clean Chain PREROUTING
function CleanPREROUTING() {
  for i in $( iptables -t nat --line-numbers -L | grep ^[0-9] | awk '{ print $1 }' | tac ); do
    iptables -t nat -D PREROUTING $i 2> /dev/null
  done
}
function DisableForwarding() {
  sysctl -w net.ipv4.ip_forward=0
}

DisableForwarding
CleanPREROUTING
echo "Chain PREROUTING NAT Rules CLEANED"
for c in "${containers[@]}"; do
  HandleContainers "$c" "stop"
done
