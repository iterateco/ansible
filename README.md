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

Target all EC2 machines with the tags env=dev and roles app or admin and execute only specific ansible playbook tags.  For instnace the following would update configuration files for apache and crontab on the admin machine.

```
-e "env=dev roles=admin" --tags=apache,crontab
```

Restart apache2 service
```
ansible-playbook -i plugins/inventory/ec2.py --user=ubuntu services.yml --private-key=~/.ssh/yourkey.pem -e 'env=dev role=app service=apache2 state=restarted'
```

### Roles

Apache configuration
````
apache_ports: [80, 443]
apache_health_check_file: health.html
apache_sites_available:
  app:
    host: "{{env}}.{{app_domain_name}}"
    ports: [80, 443]
    directory_index: "app_{{env}}.php"
    ssl: # optional
      port: 443 # port ssl will listen on
      required: false # force http => https redirect
      engine_enabled: true # turn on ssl engine
      cert_src_path: PATH_TO_SRC_CERTS  # required if engine_enabled is true.  Path to 'cert.crt', 'cert.key', 'chain.crt'.  example: /MY_PROJECT/CERTS
    directives: # optional, any custom apache directorives. Currently only supports directives outside of directory directive.
      - 'Header set Access-Control-Allow-Origin "*"'
  stc:
    host: "{{env}}-stc.{{app_domain_name}}"
    ports: [80, 443]
    directory_index: "app_{{env}}.php"
    ssl:
      port: 443
      required: false
      engine_enabled: true
      cert_src_path: PATH_TO_SRC_CERTS
    directives:
      - 'FileETag none'
      - 'ExpiresActive On'
      - 'ExpiresDefault "access plus 1 year"'
      - 'Header set Access-Control-Allow-Origin "*"'
````

App, stc are sample names of sites.  This way they can be referenced when enabling sites.
For example:  - { role: apache, apache_sites_enabled: ['app', 'stc'] }
