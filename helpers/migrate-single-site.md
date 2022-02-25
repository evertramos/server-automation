# How to migrate from Wordpress Single site into the Proxy Environment

## Requirements before start this process

Proxy should be running on their Server
Access to the DNS of the domain we are migrating

## Naming convention

For better comprehension follow the terms:
Origin Server - where the site that should be migrated are running
Proxy Server - where the proxy is running and where the site will be running after migrated

## Steps to Migrate the site to the Proxy Server

1. Access the Origin Server, find the Wordpress installation folder and cat the wp-config options to backup the database

```bash
$ cd /var/www/html/your_wordpress_site
$ cat wp-config.php | grep DB_

define('DB_NAME', your_db_name');
define('DB_USER', your_db_user');
define('DB_PASSWORD', 'your_db_password');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
```

2. Create backup folder inside the Wordpress folder and backup the database:

```bash
$ mkdir db_backup
$ mysqldump -u your_db_user --password=your_db_password your_db_name >> your_db_name.bak.sql
```

3. Create a `tar` file for the Wordpress folder

> In order to do run the tar command you must have tar and gzip installed, if you do not have run the follow: `apt install -y tar gzip`

```bash
$ cd .. # this command will go the the previous folder where you can tar the whole wordpress folder
$ pwd # if your site is located inside /var/www/html/xyz.. you should see the following
/var/www/html
$ tar -czf your_wordpress_site.tar.gz your_wordpress_site
```
 Once the tar is completed you can go to next step. This might take a few minutes depending on the size of your site.

4. Access the Proxy Server and create folder structure for your Site

4.1. Go to the path you want to create your folder structure:

/server/sites
/your_site_name
/backup # backup files
/compose # docker files 
/data # site and db files

```bash
$ cd /path/to/your/sites/folder # in server the sites are located at /server/sites
$ mkdir your_wordpress_site # create a folder for your website
$ git clone https://github.com/evertramos/docker-wordpress-letsencrypt.git compose
$ mkdir data
```

4.2 Edit the settings in the docker-compose file:

> In order to run multiple sites we must have different names for the docker services, created by the docker-compose, so we must update the docker-compose file for the wordpress installation. We will develop a script to update this automatically but is not ready yet, when it´s ready you can go to the next step directly.

> In order to use *vim* you must have it installed or run `apt install -y vim`

```bash
$ cd /server/sites/your_wordpress_site/compose
$ vi docker-compose.yml
```

Please update the following lines as of:

4.2.1 DB service name - https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/docker-compose.yml#L4

4.2.2 SITES service name - https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/docker-compose.yml#L16

4.2.3 Depends on lines with the same name of the database

Normally I use the site name as standard for the container name and service name, so, it would look like this:

```bash
version: '3'

services:
   your_site-db:
     container_name: ${CONTAINER_DB_NAME}
     image: mariadb:latest
    [...]

   your_site-site:
     depends_on:
           - your_site-db
     container_name: ${CONTAINER_WP_NAME}
     image: wordpress:latest
    [...]
#     LETSENCRYPT_HOST: ${DOMAINS} 
#     LETSENCRYPT_EMAIL: ${LETSENCRYPT_EMAIL}
[...]

#   wpcli:
#     image: tatemz/wp-cli
#     volumes:
#       - ${WP_CORE}:/var/www/html
#       - ${WP_CONTENT}:/var/www/html/wp-content
#     depends_on:
#         - your_site-db
#     entrypoint: wp
    [...]
```

4.2.4 Comment the line LETSENCRYPT_HOST and LETSENCRYPT_EMAIL in the docker-compose file as above so you can only uncomment when the dns is moved.

> [IMPORTANT] This above step is very important due the the LetsEncrypt requests limits. If we enable at this moment this might reach IP request limit and we will not be able to create our certificate for the migrating site.

4.3 Create the *.env* file and update settings

```bash
$ cp .env.sample .env
$ vi .env
```

4.3.1 Update the proxy name as configures in the proxy (in our server is **proxy**) - https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/.env.sample#L9

4.3.2 Update the CONTAINER_DB_NAME variable as of https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/.env.sample#L15

Normally we use the follow standard: your_site-db

4.3.3 Update the CONTAINER_WP_NAME variable as of https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/.env.sample#L32

Normally we use the follow standard: your_site-site

4.3.4 [IMPORTANT] If you use any prefix in your Original Wordpress Site you must update on WORDPRESS_TABLE_PREFIX variable as of https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/.env.sample#L44

4.3.5 Update the domain name as of https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/.env.sample#L47

4.3.6 Update the LetsEncrypt email address as of https://github.com/evertramos/docker-wordpress-letsencrypt/blob/6e27937686d26d3e7907fb4087aa913deaa2b191/.env.sample#L50

4.3.7 Update the Database information as you wish:

```bash
MYSQL_ROOT_PASSWORD=root_password

MYSQL_DATABASE=database_name
MYSQL_USER=user_name
MYSQL_PASSWORD=user_password
```

4.4 Start the environment 

In your compose folder you will run the following:

```bash
$ docker-compose up -d
```

This might take a few seconds to be ready.

Your site configured in the DOMAIN variable in the .env file should be available if you update your local hosts file (unix systems `/etc/hosts` - windows `C:\Windows\System32\drivers\etc\hosts`) with your site and ip address as follows:

```bash
0.0.0.0 your_site_name
```

5. Copy the site backup from the Origin Server to Proxy Server

Go the the backup folder as of the folder structure above:

```bash
$ cd /server/sites/your_site_name/backup
´´´

> In order to facilitate the communication between server we recommend using ssh keys

```bash
$ scp -P 22 root@your_origin_server_ip_address://var/www/html/your_wordpress_site.tar.gz .
```

Now your file *your_wordpress_site.tar.gz* should be locally available.

6. Decompress files and update running environment 

```bash
$ tar -xzf your_wordpress_site.tar.gz
```

Now you have your original wordpress installation from the Origin Server with the db backup sql file.

6.1 Copy *wp-content* forlder to the right place in the new environment

If you follow the regular installation and do not change the folder structure you will do the following:

> You must have sudo access to run the commands below

```bash
$ cd /server/sites/your_site_name/data/site
$ sudo mv wp-content empty.wp-content
$ sudo mv /server/sites/your_site_name/wp-content .
```

6.2 Update the database 

Once you have created a dump file we will decompress it to the running database for the site

```bash 
$ cd /server/sites/your_site_name/backup/db_backup # db_backup is the folder you created in your dump command above
```

Now you will restore the database in the db container for your site, which I recommend using the root password. Make sure you use all the variables settled in the *.env* as the following:
```bash
$ cat your_db_name.bak.sql | docker exec -i CONTAINER_DB_NAME mysql -u root --password=YOUR_ROOT_PASSWORD YOUR_DB_NAME
```

6.3 Set folders permissions

```bash
$ sudo chown www-data.www-data -R /server/sites/your_site_name/data/site/*
```

7. Test your site which should be running in your PC after you update the hosts file

Most cases you will not be able to really open the site if your ssl plugins are enabled, so you can disable plugins using wp-cli as of below:

Inside the ./compose file of your new site run the following:
```bash
$ docker-compose run --rm wpcli plugin list
```

Then you will be able to disable any plugin:
```bash
$ docker-compose run --rm wpcli plugin deactivate your_plugin_name
```

> We recommend add an alias to your ~/.bash_aliases with the following so make it easier to run wp-cli `alias wp=”docker-compose run --rm wpcli”`

8. Update your DNS records

Before update the DNS records make sure your site is running accordingly so you do not face issues then your site goes live.

9. Start the environment with the LetsEncrypt options enabled

> [IMPORTANT] You must make sure your site is already redirecting to your Proxy Server before you start the compose file with LetsEncrypt enabled.

Update your docker-compose file and uncomment the lines below:

```bash
#     LETSENCRYPT_HOST: ${DOMAINS} 
#     LETSENCRYPT_EMAIL: ${LETSENCRYPT_EMAIL}
```

Stop and star your compose environment with the following:

```bash
$ cd /server/sites/your_site_name/compose
$ docker-compose down
$ docker-compose up -d
```

------

10. You can follow the SSL Certificate creating following the logs on your letsencrypt container with the following:

```bash
$ docker logs -f --tail 50 nginx-letsencrypt
```

After your certificate is generated you will be able to access your site in the new server (Proxy Server).

