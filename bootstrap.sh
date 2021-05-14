#!/bin/bash
# this script allows developers to run different versions of ansible playbooks roles per project
# and installs ansible on VM so developers need minimal packages on host machine

LATEST_RELEASE=$(wget -qO- "https://api.github.com/repos/iterateco/ansible/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
LATEST_VERSION=${LATEST_RELEASE:1}

while getopts "c:v:" opt; do
  case $opt in
    c) COMMAND="$OPTARG"
    ;;
    v) VERSION="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

INSTALL_VERSION=${VERSION:-$LATEST_VERSION}

echo "Installing roles version $INSTALL_VERSION"

INSTALL_DIR="$HOME/.iterate/ansible"

if command -v ansible 2>/dev/null; then
  echo "Ansible already installed"
else
  echo "Installing ansible"

  # Note: installation may fail due to apt lock:
  # "Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)"
  # "Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?"
  # So we'll retry a 5 times, waiting 90 seconds in-between reties

  n=0
  until [ "$n" -ge 5 ]
  do
    n=$((n+1))
    echo "Ansible install attempt: $n"

    # install apt-get
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository -y ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install -y ansible

    command -v ansible 2>/dev/null && break
    sleep 90
  done
fi

# install ansible roles if not already installed
if [ ! -d "$INSTALL_DIR/ansible-$INSTALL_VERSION" ]; then
  sudo mkdir -p $INSTALL_DIR
  sudo wget "https://github.com/iterateco/ansible/archive/v$INSTALL_VERSION.tar.gz" -O "$INSTALL_DIR/$INSTALL_VERSION.tar.gz"
  wgetreturn=$?
  if [[ $wgetreturn -ne 0 ]]; then
    ERROR_MSG="Ansible role version not found $INSTALL_VERSION"
    echo -e "\e[01;31m$ERROR_MSG\e[0m" >&2;
    exit 1
  fi

  cd $INSTALL_DIR && sudo tar -xvf "$INSTALL_VERSION.tar.gz"
  sudo rm "$INSTALL_DIR/$INSTALL_VERSION.tar.gz"
else
  echo "$INSTALL_DIR/ansible-$INSTALL_VERSION already exists"
fi

cat >"$HOME/.ansible.cfg" <<EOL
[defaults]
host_key_checking = False
roles_path = $INSTALL_DIR/ansible-$INSTALL_VERSION/roles
filter_plugins = $INSTALL_DIR/ansible-$INSTALL_VERSION/filter_plugins
EOL

if [ ! -z "$COMMAND" ]; then
  echo "executing: $COMMAND"
  eval $COMMAND
fi

echo -e "\e[0;32mSuccess\e[0m" >&2;