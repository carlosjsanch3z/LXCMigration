#!/bin/bash

# vars
status=''
# functions
function GetStatus() {
  status=$(lxc-info -n $1 | grep 'State' | tr -s " " | cut -d " " -f 2)
}

echo "Enter the number of the container: "
read lxcname

GetStatus "$lxcname"
if [[ $status == "RUNNING" ]]; then
  case "$lxcname" in
      contenedor1)
      lxc-attach -n $lxcname -- memtester 430 10
      ;;
      contenedor2)
      lxc-attach -n $lxcname -- memtester 920 10
      ;;
  esac
  echo "Memtester started in $lxcname"
fi
