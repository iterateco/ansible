# ansible

Example commands

```
ansible-playbook -i ec2.py --user=ubuntu --private-key=yourkey.pem configure.yml -e "env=prod roles=app" --tags=apache,crontab
ansible-playbook -i ec2.py --user=ubuntu --private-key=yourkey.pem credentials.yml -e "env=prod roles=app,admin"
ansible-playbook -i ec2.py --user=ubuntu --private-key=yourkey.pem deploy.yml -e "env=prod build_id=XXX"
ansible-playbook -i ec2.py --user=ubuntu --private-kesy=yourkey.pem ami.yml
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

Example ami playbook with json variables

```
ansible-playbook -i ec2.py exmaples/ami.yml -u ubuntu --private-key=~/key.pem -e '@myamivars.json'
```

Where myamivars.json contains.  *You can optional pass in variables via command line.*
```json
{
  "ami_keypair": "mykeypair",
  "ami_name": "myaminame",
  "ami_security_group": "ami",
  "ami_instance_type": "t2.micro",
  "ami_aws_region": "us-east-1",
  "ami_vpc_subnet": "subnet",
  "ami_base_image": "ami-10389d78"
}
```

## Role Configuration
The following configuration values can be set in group_vars files and will override the defaults listed below.

- [ami](#role-ami)
- [apache](#role-apache)
- [bashprompt](#role-bashprompt)
- [common](#role-common)
- [crontab](#role-crontab)
- [deploy](#role-deploy)
- [elasticache](#role-elasticache)
- [jenkins](#role-jenkins)
- [mysql](#role-mysql)
- [nginx](#role-nginx)
- [nodejs](#role-nodejs)
- [php](#role-php)
- [ruby](#role-ruby)

<a name="role-ami"></a>
### ami
```yml
ami_keypair: mykeypair
ami_name: myaminame
ami_security_group: ami
ami_instance_type: t2.micro
ami_aws_region: us-east-1
ami_vpc_subnet: subnet
ami_base_image: ami-10389d78
```

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
bashprompt_base: localhost
bashprompt_home: /home/ubuntu
```

<a name="role-common"></a>
### common
```yml
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
```yml
crontab_list:
  - "*/1 * * * * root JOB_COMMAND --env={{ env }}"
```

<a name="role-deploy"></a>
### deploy

deploy a nodejs project
```
ansible-playbook -i ec2.py deploy.yml -u ubuntu --private-key=~/key.pem --tags=nodejs
-e 'env=prod 
roles=app 
deploy_src=site 
deploy_secrets_src=secrets.json 
deploy_exclude_path=rsync_exclude 
deploy_build_id=myBuildId'
```

deploy a symfony2 project
```
ansible-playbook -i ec2.py deploy.yml -u ubuntu --private-key=~/key.pem --tags=symfony2
-e 'env=prod 
roles=app 
deploy_src=site 
deploy_secrets_src=parameters.yml
deploy_exclude_path=rsync_exclude 
deploy_build_id=myBuildId'
```

```yml
deploy_src: "/path/to/my/site"
deploy_secrets_src: "/path/to/local/secrets.json"
deploy_secrets_dest: "/path/to/remote/secrets.json" #optional
deploy_exclude_path: "/path/to/rsync_exclude"
deploy_dest: "/path/to/deploy/directory" #optional
deploy_build_id: "myBuildId" 
```

<a name="role-elasticache"></a>
### elasticache
*no configuration variables*

<a name="role-mysql"></a>
### mysql

```yml
mysql_root_password: localpass
mysql_database_name: localdb
mysql_apt_packages:
  - mysql-server-5.6
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
```yml
nodejs_apt_packages:
  - nodejs-legacy
```

<a name="role-php"></a>
### php
```yml
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

<a name="role-ruby"></a>
### ruby
```yml
ruby_home: /home/ubuntu
ruby_path: /usr/local/bin/ruby
ruby_version: 2.2.2
ruby_apt_packages:
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
