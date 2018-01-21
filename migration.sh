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
memorylimit=''
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
    GetIP $1
    GetCurrentMemory $1
    memorylimit='40'
    MemoryTest "$1" "${memorylimit}"
  else
    #echo "El ${1} esta apagado."
    sleep 1
  fi
}

# Check State of the Container
function GetStatus() {
  status=$(lxc-info -n $1 | grep 'State' | tr -s " " | cut -d " " -f 2)
}
# Get Current IP LXC Container
function GetIP() {
  ip=$(lxc-info -n $1 | grep 'IP' | tr -s " " | cut -d " " -f 2)
  CheckVarEmpty $ip
}
#Get Memory RAM Usage LXC Container
function GetCurrentMemory() {
  memory=$(lxc-info -n $1 | grep 'Memory use' | tr -s " " | cut -d " " -f 3 | cut -d "." -f 1)
  CheckVarEmpty $memory
}
#Test Var Empty
function CheckVarEmpty() {
  if [[ -z "$1" ]]; then
    echo "No se ha encontrado el valor de la variable"
    exit 1
  fi
}
# Memory TEST
function MemoryTest() {
  if [[ "${memory}" -ge "$2" ]]; then
    echo "Start Migration"
    HandleContainers "${containerplus}" "start"
    Apachectl $1 "stop"
    Deatachvol $1
    CleanIPRule $1
    HandleContainers $1 "stop"
  fi
}
# Operation Containers
function HandleContainers() {
  case "$2" in
      start) lxc-start -n $1 2> /dev/null
      echo "Raising $1"
      ;;
      stop) lxc-stop -n $1 2> /dev/null
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


function CleanIPRule() {
  :
}
function CleanVars() {
  :
}

# Crear script q arranque el contenedor1 y añada el volumen servicio y añada las reglas ip tables
# Desarrollar la funcion CleanIPRule
# Desarrollar la funcion CleanVars
# Montar escenario en container 2
# Desarrollar condicion container 2
# Crear script purgue el escenario














start
## START

## FOR EACH CONTAINER IN ARRAY

  ## IF THE CONTAINER IS RUNNING

    ## GET IP % MEMORY CURRENT

      ## IF THE CONTAINER IS = CONT1
        ## CHECK IF THE MEMORY > 500MB

          ## STOP APACHE2 SERVICE
          ## UMOUNT LV
          ## START CONT2
          ## DELETE CURRENT IPTABLES RULES
          ## POWEROFF CONT1

          ## IF CONT2 IS AVAILABLE
            ## MOUNT LV
            ## RESTART APACHE2 SERVICE
            ## ADD NEW RULE FOR CONT2

      ## IF THE CONTAINER IS = CONT2
        ## CHECK IF THE MEMORY > 2000MB
          ## UPLOAD RAM LIMIT
