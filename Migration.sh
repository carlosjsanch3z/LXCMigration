#!/bin/bash
# LXC Migration Script
# Created on 20-01-2018
# Author: Carlos Jesús Sánchez
# Version 1.0

# VARS
containers=(contenedor1 contenedor2)
status=''
ip=''
memory=''
containerplus='contenedor2'
lvname='additional'
apachedir='/var/www/html'

# FUNCTIONS
# Start the script
function start() {
  for c in "${containers[@]}"; do
    program $c
  done
}

# Main Code
function program() {
  GetStatus $1
  if [[ "$status" == "RUNNING" || "$1" == "contenedor1" ]]; then
    MemoryTest "$1"
  elif [[ "$status" == "RUNNING" || "$1" == "contenedor2" ]]; then
    MemoryTest "$1"
  else
    echo "None of the containers is running"
  fi
}

# Check State of the Container
function GetStatus() {
  status=$(lxc-info -n $1 | grep 'State' | tr -s " " | cut -d " " -f 2)
}

# Get Current IP LXC Container
function GetIP() {
  ip=$(lxc-info -n $1 | grep 'IP' | tr -s " " | cut -d " " -f 2)
}

#Get Memory RAM Usage LXC Container
function GetCurrentMemory() {
  memory=$(lxc-info -n $1 | grep 'Memory use' | tr -s " " | cut -d " " -f 3 | cut -d "." -f 1)
}

# Memory TEST
function MemoryTest() {
  GetIP $1
  GetCurrentMemory $1
  case "$1" in
      contenedor1)
      if [[ "${memory}" -ge 400 ]]; then
        echo "Start Migration"
        HandleContainers "$containerplus" "start"
        Apachectl $1 "stop"
        Deatachvol $1
        CleanPREROUTING
        HandleContainers $1 "stop"
        BuildContPlus
      fi
      ;;
      contenedor2)
      if [[ "${memory}" -ge 900 ]]; then
        echo "$1: Ram increase live"
        lxc-cgroup -n $1 memory.limit_in_bytes 2G
      fi
      ;;
      *)
      echo "$1: RAM consumption is moderate."
      ;;
  esac
}

# Operation Containers
function HandleContainers() {
  case "$2" in
      start) lxc-start -n $1
      echo "Raising $1"
      ;;
      stop) lxc-stop -n $1 -k
      echo "Stopping $1"
      ;;
  esac
}

# Apache Control
function Apachectl() {
  case "$2" in
      stop) lxc-attach -n $1 -- systemctl stop apache2 2> /dev/null
      ;;
      restart) lxc-attach -n $1 -- systemctl restart apache2
      ;;
  esac
  ReturnCode "Systemctl Apache Failed"
}

#Catching Exceptions
function ReturnCode() {
  if [[ "$?" -ne "0" ]]; then
    echo "${1}"
    exit $?
  fi
}

# Deatach LV
function Deatachvol() {
  lxc-attach -n $1 -- umount /dev/lvm-group/${lvname}
  ReturnCode "LV not mounted"
  lxc-device -n $1 del /dev/lvm-group/${lvname}
}

# Clean NAT Prerouting rules
function CleanPREROUTING() {
  for i in $( iptables -t nat --line-numbers -L | grep ^[0-9] | awk '{ print $1 }' | tac ); do
    iptables -t nat -D PREROUTING $i 2> /dev/null
  done
}

# Add & Mount LV in Container2
function BuildContPlus() {
  lxc-device -n $containerplus add /dev/lvm-group/${lvname}
  lxc-attach -n $containerplus -- mount /dev/lvm-group/${lvname} ${apachedir}
  Apachectl "$containerplus" "restart"
  SetDNAT
}

# Set New NAT PREROUTING RULE FOR Container2
function SetDNAT() {
  ipplus=$(lxc-info -n ${containerplus} | grep 'IP' | tr -s " " | cut -d " " -f 2)
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $ipplus
}

start
