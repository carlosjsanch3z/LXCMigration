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
timeout=''


lvname=''
apachedir=''


# FUNCTIONS

function AttachLV() {
  :
}

function SetIptableRule() {
  :
}

function MemoryTest() {
  echo "Aqui se comprueba la memory: ${memory}"
  if [[ "${memory}" -ge 30 ]]; then
    echo "Supera el limite de RAM"
  fi
}

function pp() {
  GetStatus $1
  if [[ "$status" == RUNNING ]]; then
    #echo "${1} esta corriendo ..."
    #echo "Toca obtener ip y memory de ${1}"
    GetIP $1
    GetCurrentMemory $1
    #echo "${ip} - Memory: ${memory}"
    #echo "Volver a empezar"
    sleep 1
    MemoryTest $1
  else
    #echo "El ${1} esta apagado."
    sleep 1
  fi
}

function GetCurrentMemory() {
  memory=$(lxc-info -n $1 | grep 'Memory use' | tr -s " " | cut -d " " -f 3 | cut -d "." -f 1)
}

function GetIP() {
  ip=$(lxc-info -n $1 | grep 'IP' | tr -s " " | cut -d " " -f 2)
}

function GetStatus() {
  status=$(lxc-info -n $1 | grep 'State' | tr -s " " | cut -d " " -f 2)
}

function start() {
  for c in "${containers[@]}"; do
    pp $c
  done
  start
}

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
