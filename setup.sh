#!/bin/bash
# Example setup command
# sudo -E ./setup.sh -i
set -e

# Environment variable
WORKDIR=$(pwd)

# Constant for color text
RED='\033[0;31m'
L_GREEN='\033[1;32m'
D_GREEN='\033[0;32m'
L_BLUE='\033[1;34m'
D_BLUE='\033[0;34m'
L_RED='\033[1;31m'
D_RED='\033[0;31m'
L_YEL='\033[1;33m'
D_YEL='\033[0;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo -e "${L_GREEN}Source environment variable in /etc/environment.${NC}"
source /etc/environment

install() {
  echo -e "${L_BLUE}Running Installation.${NC}"
}

uninstall() {
  echo -e "${L_BLUE}Running Uninstallation.${NC}"
}

errorCommand() {
  echo -e "${L_RED}Error Command input. Check with the usage below.${NC}"
}

usage() {
  echo -e "Usage: ./$(basename $0) [OPTION]"
  echo -e "Example: ./$(basename $0) -i"
  echo -e "Example (dev): DEV=1 ./$(basename $0) -i"
  echo -e "-i | --install   \t Install configuration and deploy application"
  echo -e "-u | --uninstall \t Remove application and uninstall configuration"
}

for arg in "$@"; do
  shift
  case "$arg" in
  '--install') set -- "$@" '-i' ;;
  '--uninstall') set -- "$@" '-u' ;;
  '--help') set -- "$@" '-h' ;;
  *) set -- "$@" "$arg" ;;
  esac
done

while getopts ":iuh" OPTION; do
  case "$OPTION" in
  i)
    install
    exit 0
    ;;
  u)
    uninstall
    exit 0
    ;;
  h)
    usage
    exit 0
    ;;
  ?)
    errorCommand
    usage
    exit 0
    ;;
  esac
done

# usage
