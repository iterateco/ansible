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

## Role Configuration
- [apache](#role-apache)
- [bashprompt](#role-bashprompt)
- [common](#role-common)
- [crontab](#role-crontab)
- [elasticache](#role-elasticache)
- [jenkins](#role-jenkins)
- [mysql](#role-mysql)
- [nodejs](#role-nodejs)
- [php](#role-php)

<a name="role-apache"></a>
### apache
````
apache_ports: [80, 443]
apache_health_check_file: health.html
apache_ssl_path: /etc/apache2/certs
apache_htpasswd_path: /etc/apache2/.htpasswd
apache_sites_available:
  app:
    host: "{{env}}.{{app_domain_name}}"
    ports: [80, 443]
    directory_index: "app_{{env}}.php"
    basic_auth: # optional
      authname: MySite
      username: myusername
      password: mypassword
    ssl: # optional
      port: 443 # port ssl will listen on
      required: false # force http => https redirect
      engine_enabled: true # turn on ssl engine
      cert_src_path: /path/to/ssl/certs  # required if engine_enabled is true.  Assumes following files exists at path. ['cert.crt', 'cert.key', 'chain.crt']
    directives: # optional, any custom apache directorives. Currently only supports directives outside of directory directive.
      - 'Header set Access-Control-Allow-Origin "*"'
  stc:
    host: "{{env}}-stc.{{app_domain_name}}"
    ports: [80]
    directory_index: "app_{{env}}.php"
    directives:
      - 'FileETag none'
      - 'ExpiresActive On'
      - 'ExpiresDefault "access plus 1 year"'
      - 'Header set Access-Control-Allow-Origin "*"'
````

App, stc are sample names of sites.  This way they can be referenced when enabling sites.
For example:  
```
- { role: apache, apache_sites_enabled: ['app', 'stc'] }
```
<a name="role-bashprompt"></a>
### bashprompt
*no configuration variables*

<a name="role-common"></a>
### common
```
common_packages:
  - {name: acl, manager: apt}
  - {name: git, manager: apt}
  - {name: vim, manager: apt}
  - {name: zip, manager: apt}
  - {name: apache2, manager: apt}
  - {name: mysql-client-5.6, manager: apt}
  - {name: mysql-server-5.6, manager: apt}
  - {name: curl, manager: apt}
  - {name: ntp, manager: apt}
  - {name: nodejs-legacy, manager: apt}
  - {name: npm, manager: apt}
  - {name: apache2-utils, manager: apt}
  - {name: build-essential, manager: apt}
  - {name: libssl-dev, manager: apt}
  - {name: libexpat1-dev, manager: apt}
  - {name: rsync, manager: apt}
  - {name: memcached, manager: apt}
  - {name: libapache2-mod-php5, manager: apt}
  - {name: php5, manager: apt}
  - {name: php-apc, manager: apt}
  - {name: php-soap, manager: apt}
  - {name: php-pear, manager: apt}
  - {name: php5-cli, manager: apt}
  - {name: php5-curl, manager: apt}
  - {name: php5-mysql, manager: apt}
  - {name: php5-intl, manager: apt}
  - {name: php5-gd, manager: apt}
  - {name: php5-mcrypt, manager: apt}
  - {name: php5-memcached, manager: apt}
  - {name: python-mysqldb, manager: apt}
  - {name: python-keyczar, manager: apt}
  - {name: python-setuptools, manager: apt}
  - {name: python-dev, manager: apt}
  - {name: python-pip, manager: apt}
  - {name: ansible, manager: pip}
  - {name: jinja2, manager: pip}
  - {name: boto, manager: pip}
  - {name: uglify-js, manager: npm}
  - {name: uglifycss, manager: npm}
  - {name: forever, manager: npm}
```

<a name="role-crontab"></a>
### crontab
```
crontab_list:
  - "*/1 * * * * root TERM=dumb {{ app_command }} JOB_COMMAND --env={{ env }}"
```

<a name="role-elasticache"></a>
### elasticache
*no configuration variables*

<a name="role-mysql"></a>
### mysql

```
mysql_root_password: localpass
```

<a name="role-jenkins"></a>
### jenkins
```
jenkins_url: localhost
jenkins_port: 8080
jenkins_cli_dest: /usr/local/bin/jenkins-cli.jar
jenkins_plugins:
  - scm-api
  - git-client
  - git
  - slack

```

<a name="role-nodejs"></a>
### nodejs
*no configuration variables*

<a name="role-php"></a>
### php
```
php_memory_limit: 256M
php_upload_max_filesize: 250M
php_max_file_uploads: 10
php_max_execution_time: 120
php_display_errors: Off
php_display_startup_errors: Off
```



