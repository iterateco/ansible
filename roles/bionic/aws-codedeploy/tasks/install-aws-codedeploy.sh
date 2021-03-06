#!/bin/bash
# https://github.com/aws/aws-codedeploy-agent/issues/158
# Install aws-codedeploy-agent and required gems
sudo apt-get install -y git
codedeploy_git_url='https://github.com/aws/aws-codedeploy-agent.git'
git clone "$codedeploy_git_url"
sudo gem install bundler
sudo mv aws-codedeploy-agent /opt/codedeploy-agent
cd /opt/codedeploy-agent
bundle install --system

# Setup permissions
sudo chown -R root.root /opt/codedeploy-agent
sudo chmod 644 /opt/codedeploy-agent/conf/codedeployagent.yml
sudo chmod 755 /opt/codedeploy-agent/init.d/codedeploy-agent
sudo chmod 644 /opt/codedeploy-agent/init.d/codedeploy-agent.service

# Create symlink to match ./install setup
sudo mkdir -p /etc/codedeploy-agent
sudo ln -s /opt/codedeploy-agent/conf /etc/codedeploy-agent/conf

# Move init scripts
sudo mv /opt/codedeploy-agent/init.d/codedeploy-agent /etc/init.d/codedeploy-agent
sudo mv /opt/codedeploy-agent/init.d/codedeploy-agent.service \
        /lib/systemd/system/codedeploy-agent.service

# Delete RHEL init info since this is for Ubuntu Bionic
sudo sed -i.bak '2,8d' /etc/init.d/codedeploy-agent && \
sudo rm -f /etc/init.d/codedeploy-agent.bak

# Enable init.d scripts to start at boot
sudo /etc/init.d/codedeploy-agent start && echo ''
sudo /usr/sbin/update-rc.d codedeploy-agent defaults
sudo /usr/sbin/update-rc.d codedeploy-agent enable

# Cleanup
files=(.git
    CODE_OF_CONDUCT.md
    CONTRIBUTING.md
    Gemfile.lock
    LICENSE
    NOTICE
    README.md
    Rakefile
    buildspec-agent-rake.yml
    coverage
    deployment
    features
    spec
    test)

cd /opt/codedeploy-agent

for f in "${files[@]}";do
    sudo rm -rf "$f"
done