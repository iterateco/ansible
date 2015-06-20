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

Install all ansible roles

```
-e "env=dev roles=admin" --tags=install
```

Configure on all ansible roles

```
-e "env=dev roles=admin" --tags=configure
```

Configure php role only

```
-e "env=dev roles=admin" --tags=configure:php
```

Install php only

```
-e "env=dev roles=admin" --tags=install:php
```

Install php,apache only

```
-e "env=dev roles=admin" --tags=install:php,install:apache
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
apache_apt_packages:
  - apache2-utils
  - apache2
  - libapache2-mod-php5
apache_sites_available:
  app:
    host: "{{env}}.{{app_domain_name}}"
    ports: [80, 443]
    directory_index: "app_{{env}}.php"
    document_root: /var/www/current/Symfony/web
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
    document_root: /var/www/current/Symfony/web
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
```
bashprompt_base: localhost
bashprompt_home: /home/ubuntu
```

<a name="role-common"></a>
### common
```
common_apt_packages:
  - acl
  - git
  - vim
  - zip
  - mysql-client-5.6
  - curl
  - ntp
  - npm
  - build-essential
  - libssl-dev
  - libexpat1-dev
  - rsync
  - memcached
  - python-mysqldb
  - python-keyczar
  - python-setuptools
  - python-dev
  - python-pip

common_pip_packages:
  - ansible
  - jinja2
  - boto

common_npm_packages:
  - uglify-js
  - uglifycss
  - forever
```

<a name="role-crontab"></a>
### crontab
```
crontab_list:
  - "*/1 * * * * root JOB_COMMAND --env={{ env }}"
```

<a name="role-elasticache"></a>
### elasticache
*no configuration variables*

<a name="role-mysql"></a>
### mysql

```
mysql_root_password: localpass
mysql_database_name: localdb
mysql_apt_packages:
  - mysql-server-5.6
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
```
nodejs_apt_packages:
  - nodejs-legacy
```

<a name="role-php"></a>
### php
```
php_memory_limit: 256M
php_upload_max_filesize: 250M
php_max_file_uploads: 10
php_max_execution_time: 120
php_display_errors: Off
php_display_startup_errors: Off
php_apt_packages:
  - php5
  - php-apc
  - php-soap
  - php-pear
  - php5-cli
  - php5-curl
  - php5-mysql
  - php5-intl
  - php5-gd
  - php5-mcrypt
  - php5-memcached
```



