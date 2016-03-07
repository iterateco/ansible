#!/bin/bash
# this script allows developers to run different versions of ansible playbooks roles per project
# and installs ansible on VM so developers need minimal packages on host machine

while getopts "p:v:" opt; do
  case $opt in
    p) ANSIBLE_PLAYBOOK="$OPTARG"
    ;;
    v) INSTALL_VERSION="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

INSTALL_DIR="$HOME/.iterate/ansible"

if command -v ansible 2>/dev/null; then
  echo "ansible already installed"
else
  echo "installing ansible"
  sudo apt-get update
  sudo apt-get install -y python-pip python-dev
  sudo pip install -U pip
  sudo pip install ansible
fi

# install ansible roles if not already installed
if [ ! -d "$INSTALL_DIR/ansible-$INSTALL_VERSION" ]; then
  sudo mkdir -p $INSTALL_DIR
  sudo wget "https://github.com/iterateco/ansible/archive/v$INSTALL_VERSION.tar.gz" -O "$INSTALL_DIR/$INSTALL_VERSION.tar.gz"
  wgetreturn=$?
  if [[ $wgetreturn -ne 0 ]]; then
    >&2 echo -e "\e[31m ansible role version not found $INSTALL_VERSION"
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

if [ ! -z $ANSIBLE_PLAYBOOK ]; then
  ansible-playbook $ANSIBLE_PLAYBOOK
else
  echo "no playbook"
fi