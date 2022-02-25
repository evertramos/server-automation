# Base Script Example

This script is meant to 

## How to use

### Tutorial 

[![Video](http://img.youtube.com/vi/_rTaZQ5-tTg/0.jpg)](https://www.youtube.com/watch?v=_rTaZQ5-tTg "Backup")

Video https://www.youtube.com/watch?v=_rTaZQ5-tTg

> In order to run this backup script you must have sudo right and NOPASSWD set in the sudoers config.

### Step by Step

#### Config once

After cloning this repo you should follow the steps below:

1. Configure your *.env* file

1.1 Copy the file .env.example to .env 
```bash
$ cp .env.exempla .env
```

1.2 Set your site and backup folder, as of:
```bash
$ vi .env

[...]
SITES_FOLDER=/server/sites

BACKUP_FOLDER=/server/backup/sites/
```

#### Usage

2. Run the backup script

Before you run the backup script you could check the helper:

```bash
$ ./backup_wp.sh -h
Usage:
    backup_wp.sh -s source_folder | -u site_url [--debug] [--silent]

    Required
    -s | --source               Folder where the docker-compose.yml for the running site is located
    -u | --url                  Site url that should be located in the 'SITES_FOLDER' configures in your .env file.
                                The folder name must match with the site url, otherwise please use -s option.

    Alternatively you may inform the options below
    --debug                     Show all steps of the script execution
    --silent                    Hide all message
    -h | --help                 Display this help
```

**You must inform at least the Source Folder OR the URL in order to run the backup script.**

Using the Source option:
```bash
$ ./backup_wp.sh -s /server/sites/bmcanada.org --debug
```

Using the URL option:
```bash
$ ./backup_wp.sh -u bmcanada.org --debug
```

After you ran the backup you will find a "tar gz" file in your "BACKUP_FOLDER" you set in the .env file. 
```bash
$ ls -la /server/backup/sites
-rw-rw-r--+ 1 root  root  745921333 Mar  5 14:56 20200305_145415-bmcanada.org.tar.gz
-rw-rw-r--+ 1 root  root  746368258 Mar  5 15:02 20200305_150130-bmcanada.org.tar.gz
```

> Please note that the bakcup files are prefixed with the date and hour as of year-month-day_hour-minute-seconds-folder/site-name.tar.gz (ex. 20200305_150130-bmcanada.org.tar.gz)


## Output messages

In some cases, when site is in production some changes during the backup proccess might happen. In this case you might see some messages like:

```bash
tar: bmcanada.org/data/db/ib_logfile0: file changed as we read it
tar: bmcanada.org/data/site/wp-content: file changed as we read it
```

You don´t need to worry about those messages once it does not influence in the backup process.


The regular output for the backup process should look like the following:

```bash
[start]--------------------------------------------------
...running function "check_local_env_file" to:
Check if '.env' file is set.
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_running_script" to:
Check if there is another instance of the script running...
pid: /server/scripts/backup-wp/.backup_script.pid
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_folder_exists" to:
Checking if folder /server/sites/bmcanada.org exists.
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "backup_folder" to:
Backing up folder /server/sites/bmcanada.org to /server/backup/sites/.
>>> Success!
[end]----------------------------------------------------

Your backup was finished: 20200305_145415-bmcanada.org.tar.gz at /server/backup/sites/
```



