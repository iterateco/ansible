#!/bin/bash
# we install ansible via a script so that hosts that do not have ansible installed 
# can install it before prior to running roles

while getopts "p:" opt; do
  case $opt in
    p) INSTALL_DIR="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

cat >"$INSTALL_DIR/.ansible.cfg" <<EOL
[defaults]
host_key_checking = False
roles_path = $INSTALL_DIR/roles
filter_plugins = $INSTALL_DIR/filter_plugins
EOL