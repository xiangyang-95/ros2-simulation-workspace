#!/bin/bash
# Example setup command
# sudo -E ./setup.sh -i
set -e

# Environment variable
WORKDIR=$(pwd)

# Constant for color text
RED='\033[0;31m'
L_GREEN='\033[1;32m' # Environment related
D_GREEN='\033[0;32m'
L_BLUE='\033[1;34m' # Function related
D_BLUE='\033[0;34m'
L_RED='\033[1;31m' # Error related
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

# Usage: generic function to check internet connectivity
verifyInternet() {
  NET_INTERNET=$(
    $PROXY wget -q -T 1 --spider https://www.google.com
    echo $?
  )
  if [ ! $NET_INTERNET == 0 ]; then
    echo -e "${L_RED}Error: No internet connectivity${NC}"
    exit 1
  fi
}

verifyDockerEngine() {
  echo -e "${L_BLUE}Verifying docker engine dependency${NC}"
  if ! [ -x "$(command -v docker)" ]; then
    echo -e "Downloading & installing 'docker'"
    verifyInternet
    $PROXY apt update &&
      $PROXY apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common &&
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - &&
      add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable" &&
      apt update &&
      apt install -y docker-ce docker-ce-cli containerd.io docker-compose
  else
    echo -e "Docker & docker-compose installed"
  fi
}

installDependencies() {
  verifyDockerEngine
  pullDockerImages
}

pullDockerImages() {
  echo -e "${L_BLUE}Pulling mongodb docker image${NC}"
  docker pull mongo:6.0
}

deployServerApplications() {
  echo -e "${L_BLUE}Deploying server applications${NC}"
  cd $WORKDIR/setup
  docker compose -f docker-compose.server.yml up -d
}

removeServerApplications(){
  echo -e "${L_BLUE}Removing server applications${NC}"
  cd $WORKDIR/setup
  docker compose -f docker-compose.server.yml down
}

start() {
  echo -e "${L_BLUE}Starting the applications${NC}"
  deployServerApplications
}

stop(){
  echo -e "${L_BLUE}Stopping the applications${NC}"
  removeServerApplications
}

install() {
  echo -e "${L_BLUE}Running Installation${NC}"
  installDependencies
  start
  echo -e "${L_BLUE}Installation completed${NC}"
}

uninstall() {
  echo -e "${L_BLUE}Running Uninstallation${NC}"
  stop
}

errorCommand() {
  echo -e "${L_RED}Error Command input. Check with the usage below${NC}"
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
