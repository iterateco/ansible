#!/bin/bash
# this script allows developers to run different versions of ansible playbooks roles per project
# and installs ansible on VM so developers need minimal packages on host machine

while getopts "c:v:" opt; do
  case $opt in
    c) COMMAND="$OPTARG"
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
  # install via pip. ansible 2.0.2.0
  # http://stackoverflow.com/questions/29134512/insecureplatformwarning-a-true-sslcontext-object-is-not-available-this-prevent
  # these packages are required to prevent urllib3 from configuring SSL appropriately apt [libffi-dev libssl-dev], pip [pyopenssl ndg-httpsclient pyasn1]
  # sudo apt-get update
  # sudo apt-get install -y python-pip python-dev libffi-dev libssl-dev
  # sudo -H pip install pyopenssl ndg-httpsclient pyasn1
  # sudo -H pip install -U pip
  # sudo -H pip install ansible
  # sudo -H pip install --upgrade setuptools

  # install apt-get
  sudo apt-get -y update
  sudo apt-get install -y software-properties-common
  sudo apt-add-repository -y ppa:ansible/ansible
  sudo apt-get -y update
  sudo apt-get install -y ansible
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

echo "executing: $COMMAND"
eval $COMMAND