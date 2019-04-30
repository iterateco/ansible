### Build a Docker image from a playbook
```
docker build -t iterate/ubuntu-bionic --build-arg IMAGE=ubuntu:bionic --build-arg PLAYBOOK=playbooks/bionic.yml .
```

### Run a playbook on localhost
If playbook is outside of source directoy you can specify environment variable ANSIBLE_ROLES_PATH
```
ANSIBLE_ROLES_PATH=/path/to/roles ansible-playbook playbooks/bionic.yml
```

### Create an AMI for builds and deployment from docker container

1. Use bionic docker image as it already has ansible installed
```
docker run -v $(pwd):/project:cached -it iterate/ubuntu-bionic
```

2. Install packer and create packer.json file
```
https://releases.hashicorp.com/packer/1.4.0/packer_1.4.0_linux_amd64.zip

```

3. Create packer.json with appropriate AMI via https://cloud-images.ubuntu.com/locator/ec2/
```
{
  "builders": [
    {
      "type": "amazon-ebs",
      "instance_type": "m3.medium",
      "source_ami": "ami-920b10ed",
      "ami_name": "iterate-bionic-{{timestamp}}",
      "ssh_username": "ubuntu"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update",
        "sudo dpkg --configure -a",
        "sudo apt install -y python"
      ]
    },
    {
      "type": "ansible",
      "playbook_file": "/path/playbooks/ami.yml",
      "user": "ubuntu",
      "extra_arguments" : ["-vvv"]
    }
  ]
}
```

4. Create AMI
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_REGION=""

ANSIBLE_ROLES_PATH=/path/to/roles packer build packer.json
```