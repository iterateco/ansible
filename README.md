# ansible

Example commands

```
ansible-playbook -i plugins/inventory/ec2.py --user=ubuntu --private-key=~/.ssh/yourkey.pem configure.yml -e "env=prod roles=app" --tags=apache,crontab
ansible-playbook -i plugins/inventory/ec2.py --user=ubuntu --private-key=~/.ssh/yourkey.pem credentials.yml -e "env=prod roles=app,admin"
ansible-playbook -i plugins/inventory/ec2.py --user=ubuntu --private-key=~/.ssh/yourkey.pem deploy.yml -e "env=prod build_id=XXX"
ansible-playbook -i plugins/inventory/ec2.py --user=ubuntu --private-key=~/.ssh/yourkey.pem ami.yml
```

Target all EC2 machines with the tags env=prod and roles=app

```
-e "env=prod roles=app"
```

Target all EC2 machines with the tags env=dev and roles app or admin

```
-e "env=dev roles=app,admin"
```
