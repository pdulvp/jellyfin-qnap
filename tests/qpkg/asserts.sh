#!/bin/bash

equals(){
  if [ "$1" = "$2" ]; then
    echo 0
  else
    echo 1
  fi
}

not_contains(){
  if [[ "$1" != *"$2"* ]]; then
    echo 0
  else
    echo 1
  fi
}

file_not_exists(){
  if [ -f "$1" ]; then
    echo 1
  else
    echo 0
  fi
}

folder_not_exists(){
  if [ -d "$1" ]; then
    echo 1
  else
    echo 0
  fi
}

file_exists(){
  if [ -f "$1" ]; then
    echo 0
  else
    echo 1
  fi
}

folder_exists(){
  if [ -d "$1" ]; then
    echo 0
  else
    echo 1
  fi
}

contains(){
  if [[ "$1" == *"$2"* ]]; then
    echo 0
  else
    echo 1
  fi
}

log_assertion(){
  if [ "$1" = "0" ]; then
    green "- [OK]: $2"
  else
    red "- [KO]: $2"
  fi
}

green(){
  echo -e "\e[32m$1\e[0m"
}
red(){
  echo -e "\e[31m$1\e[0m"
}

main_test() {
  green "== Start $0"
}
sub_test() {
  green "=== $1"
}
main_test
