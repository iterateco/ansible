#!/bin/bash
# install ansible for ubuntu 14.04 to work with roles contained in this package

INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#install ansible if not already install it
if command -v ansible 2>/dev/null; then
  echo "ansible already installed"
else
  echo "installing ansible"
  sudo apt-get update
  sudo apt-get install -y python-pip python-dev
  sudo pip install -U pip
  sudo pip install ansible
fi

cat >"$HOME/.ansible.cfg" <<EOL
[defaults]
host_key_checking = False
roles_path = $INSTALL_DIR/roles
filter_plugins = $INSTALL_DIR/filter_plugins
EOL