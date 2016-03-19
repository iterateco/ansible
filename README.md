# ansible

Example commands

```
ansible-playbook -i ec2.py --user=ubuntu --private-key=yourkey.pem configure.yml -e "env=prod roles=app" --tags=apache,crontab
ansible-playbook -i ec2.py --user=ubuntu --private-key=yourkey.pem deploy.yml -e "env=prod build_id=XXX"
ansible-playbook --user=ubuntu --private-key=yourkey.pem ami.yml
```

Target all EC2 machines with the tags env=prod and roles=app.

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

Install php and apache only

```
-e "env=dev roles=admin" --tags=install:php,install:apache
```

Restart apache2 service
```
ansible-playbook -i plugins/inventory/ec2.py --user=ubuntu services.yml --private-key=~/.ssh/yourkey.pem -e 'env=dev role=app service=apache2 state=restarted'
```

## Playbooks
See examples in /examples.

Example PHP playbook. ```apache_sites_enabled``` most be defined in group_vars.
```yml
---
- hosts: all
  sudo: true
  roles:
    - common
    - php
    - { role: apache, apache_sites_enabled: ['app', 'stc'] }
    - mysql
    - bashprompt
```

Example Rails playbook. ```nginx_sites_enabled``` most be defined in group_vars.
```yml
---
- hosts: all
  sudo: true
  roles:
    - common
    - ruby
    - { role: nginx, nginx_sites_enabled: ['app'] }
    - mysql
    - bashprompt
```


## Role Configuration
The following configuration values can be set in group_vars files and will override the defaults listed below.

- [ami](#role-ami)
- [apache](#role-apache)
- [bashprompt](#role-bashprompt)
- [common](#role-common)
- [crontab](#role-crontab)
- [elasticache](#role-elasticache)
- [jenkins](#role-jenkins)
- [mysql](#role-mysql)
- [nginx](#role-nginx)
- [nodejs](#role-nodejs)
- [php](#role-php)
- [postgresql](#role-postgresql)
- [ruby](#role-ruby)

<a name="role-apache"></a>
### apache
```yml
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
```yml
- { role: apache, apache_sites_enabled: ['app', 'stc'] }
```
<a name="role-bashprompt"></a>
### bashprompt
```yml
bashprompt_base: "{{ app_name }}."
bashprompt_paths:
  - /root
  - "/home/{{ ssh_user }}"
```

<a name="role-common"></a>
### common
```yml
defaults:
  - acl
  - vim
  - zip
  - curl
  - ntp
  - rsync
```

<a name="role-crontab"></a>
### crontab
```yml
crontab_list:
  - "*/1 * * * * root JOB_COMMAND --env={{ env }}"
```

<a name="role-elasticache"></a>
### elasticache
*no configuration variables*

<a name="role-mysql"></a>
### mysql

```yml
mysql_root_password: localpass
mysql_database_name: localdb
```

<a name="role-jenkins"></a>
### jenkins
```yml
jenkins_url: localhost
jenkins_port: 8080
jenkins_cli_dest: /usr/local/bin/jenkins-cli.jar
jenkins_plugins:
  - scm-api
  - git-client
  - git
  - slack

```

<a name="role-nginx"></a>
### nginx
```yml
nginx_main_directives: []
nginx_http_directives: []
nginx_apt_packages:
  - nginx-full
  - passenger
nginx_sites_available:
  app:
    host: "{{env}}.{{app_domain_name}}"
    rails_env: development
    document_root: /var/www/current/public
```

<a name="role-nodejs"></a>
### nodejs

<a name="role-php"></a>
### php
```yml
php_memory_limit: 256M
php_upload_max_filesize: 250M
php_max_file_uploads: 10
php_max_execution_time: 120
php_display_errors: Off
php_display_startup_errors: Off
packages:
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

<a name="role-postgresql"></a>
### postgresql
```yml
postgresql_database_name: localdb
postgresql_database_user: root
postgresql_database_password: md535c31a9780a09cbaafba7817d2c33323 # localpass
postgresql_database_user_roles: CREATEDB,CREATEROLE,SUPERUSER

```

Currently, using md5 for postgresql authentication. the password should be created in format
```shell
# http://docs.ansible.com/postgresql_user_module.html
# md5 + (password) + username
echo "md5`echo -n "localpassansible" | md5`" # md5552773cdf433a60ae5d044b1cc2e95ef
```

To connect with postgresql,
```shell
psql -d ansible_local -U ansible -W
```

with password `localpass`

<a name="role-ruby"></a>
### ruby
```yml
ruby_home: /home/ubuntu
ruby_path: /usr/local/bin/ruby
ruby_version: 2.2.2
packages:
  - curl
  - zlib1g-dev
  - build-essential
  - libssl-dev
  - libreadline-dev
  - libyaml-dev
  - libsqlite3-dev
  - sqlite3
  - libxml2-dev
  - libxslt1-dev
  - libcurl4-openssl-dev
  - python-software-properties
  - libffi-dev
  - libmysqlclient-dev
```

The following packages might be needed for rails as without them passenger was throwing a "execJs: 'Could not find a JavaScript runtime'" error.

- gem 'execjs'
- gem 'therubyracer'

Please note that some people suggest using nodejs-legacy apt package
nodejs-legacy # needed for rails

http://stackoverflow.com/questions/9202324/execjs-could-not-find-a-javascript-runtime-but-execjs-and-therubyracer-are-in


## rails setup
From project directory
```
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
sudo gem install bundler
bundle install
rake db:create
rake db:migrate
```
Populate project/config/secrets.yml file with proper credentials
