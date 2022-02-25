# Backup scripts

The name speaks for itself, right? But here we go...

## What does it do?

The _backup scripts_ was designed to run a complete solution for **backup** sites, **restore** site from backup file and **cleanup** old backup files.

## Right! How does it work?

The _script_ create a _.tar.gz_ file of the whole site environmnet (docker files, db files and site files).

## How to use

Here we will detail all the basic funcionality of the backup scripts, for further (full) information please check our [Wiki](../wikis/scripts/backup).

### Video tutorial

Here is a small video (not that small, but...) so you can see it in action!

**TODO - NEED TO UPDATE THIS VIDEO WITHE THE NEW VERSION!!!**

[![Video](http://img.youtube.com/vi/_rTaZQ5-tTg/0.jpg)](https://www.youtube.com/watch?v=_rTaZQ5-tTg "Backup")

Video https://www.youtube.com/watch?v=_rTaZQ5-tTg

### Requirements

1. Config the [initial setup](../wikis/initial-setup) 

2. User must have **sudo right** and _NOPASSWD_ set in the sudoers config file

3. Config the local _.env_ file at backup script folder [Wiki](../wikis/scripts/backup) (**@TODO - UPDATE WITH ABSOLUT PATH**)

### Backup script (_backup.sh_)

Here is the _helper_ for this script:

```bash
$ /server/scripts/backup/backup.sh -h

Usage:
    backup.sh [-s source_folder] [-d destination_folder]
              [-u site_url] [--all-sites]
              [--backup-id=20200720_010359]
              [--send-storage] [--local-only]
              [--delete-local]
              [--filter="string"]
              [--yes]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -s | --source       Location where all your sites's folders are
    -d | --destination  Location where you want to place your local backup files
    -u | --url          Site URL that should backup
                        set the 'SITES_FOLDER' path in your '.env' file.
    --backup-id         The IDentification for you backup
                        [IMPORTANT] It is always recommended you use an id for your
                        backups, this way you will be able to identity your backup files
                        The default value for the backup id is 'YearMonthDay'
    --all--sites        This option will backup all your sites in your source folder
                        [VERY IMPORANT] This option takes a lot of space in your disk
                        before you use it make sure you have enough space left to
                        backup all your sites at once.
    --local-only        Backup only in local server, do not send to backup storage
    --send-storage      Send backup file to ftp storage
    --delete-local      Delete local file after backup is done. This option only
                        works when --local-only is NOT set.
    --filter=""         In order to filter the list of foler/URL you may inform the
                        option '--filter' to show only the ones that contains a
                        certain string.
    --yes               Set "yes" to all, use it with caution
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help
```

The options should _speak_ for themselves... but I know we can never think in everything... so here goes the basics:

1. Running the script

```bash
$ /server/scripts/backup/backup.sh
```

When you run the script without any option, it will pop up the questions about which site you want to backup and if you want to send it to a remote server etc.

**Please read it all carefuly before answer the script questions** 

2. Full examples

2.1 Backup locally

Here we will backup the site _christforyou.info_ locally without any questions:

```bash
$ /server/scripts/backup/backup.sh -u christforyou.info --local-only
```

2.2 Send to storage only

```bash
$ /server/scripts/backup/backup.sh -u christforyou.info --send-storage --delete-local
```

2.3 Filter all sites with a 'string' to choose

In this ecample we will filter all sites running under the domain _biblemission.digital_:

```bash
$ /server/scripts/backup/backup.sh --filter=biblemission
```

This will show the following:

```bash
[...]

[start]---------------------------------------------------------------
...running function "select_folder" to:
-----------------------------------------------------

Select one of the SITES/FOLDERS below:

   course222.biblemission.digital
   kapai.biblemission.digital
   sofiachurch.biblemission.digital

```

It will show you all options that has the _string_ 'biblemission.digital' at the sites folder (/server/sites), then you select one using the arrow keys (up and down) and press enter.

3. Backup files

All backups will be located at _/server/backup/sites_ or the path you have configured at option _'SITES_FOLDER'_ in the base _.env_ file ([initial setup](../wikis/initial-setup)).


```bash
$ ls -lah /server/backup/sites

drwxrwxr-x+ 2 evert evert 4.0K Jul 20 01:19 .
drwxrwxr-x+ 7 evert evert 4.0K Jul  7 09:33 ..
-rw-rw-r--+ 1 root  root   33M Jul 20 01:19 christforyou.info-20200720_011900.tar.gz
```

Please note that the files has a date 'id', as of _'-20200720_011900'_, which uses the current date of the server in the following oder _year + month + day + hour + minute + seconds_.

4. Backup all sites (yes! This is possible)

Using this option you will backup all files at once. It is possible to backup all sites locally, but we _strongly_ recommend to use both option _'--send-storage'_ and _'--delete-local'_ due to server disk space. Here is an example:

```bash
$ /server/scripts/backup/backup.sh --all-sites --backup-id="$(date "+%Y%m%d")" --send-storage --delete-local
```

This line above will create backup with the current date as a tag and send all files to storage, deleting the local backup file. This line is the one set at the crontab to backup all sites to our backup storage.

#### Caveats

In some cases, when site is in production some changes are made (in the site) during the backup proccess, so, when it happens you might see the message below:

```bash
tar: christforyou.info/data/db/ib_logfile0: file changed as we read it
tar: christforyou.info/data/site/wp-content: file changed as we read it
```

You don´t need to worry about those messages once it does not influence in the backup process.

### Restore script (_restore.sh_)

The script will restore a backup from a file in _local_ or _remote_ server.

Here is the _helper_ for this script:

```bash
$ /server/scripts/backup/restore.sh -h

Usage:
    restore.sh [-s source_folder] [-d destination_folder]
              [-f back_file_full_path]
              [-nu new_site_url]
              [--from-storage]
              [--no-backup] [--backup-if-running]
              [--with-www]
              [--filter="string"]
              [-rsf path_temp_folder]
              [--yes]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -s | --source       Location for the backup file
    -d | --destination  Location where you want restore the backup file
    -f | --file-name    Full path for the backup file you want to restore
    -nu | --new-url     This option will restore the backup file to a specific url
                        It will update all fields in the database from the restored
                        files and also set the url at the wp-config.php
    --from-storage      List backup files from the backup storage
    --no-backup         Run the script without backing up if there is a running site
    --backup-if-running Backup the site without prompt to the user if site is running
    --with-www          Set the 'www' to the new url informed
    --filter=""         In order to filter the list of foler/URL you may inform the
                        option '--filter' to show only the ones that contains a
                        certain string.
    -rsf                This option should only be used to change the basic option
                        set in the .env file to a new temporary folder that will be
                        used by the script to restore the backup
                        [IMPORTANT] The folder should be empty and it will be
                        totally ereased after the script execution
    --yes               Set "yes" to all, use it with caution
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help
```

Once again the options should _speak_ for themselves... but I know we can never think in everything... so here goes the basics:

1. Running the script

In most cases you will be asked to add _'filter'_ when running this script, due to many backup files what will be shown in the select list, so, we recommend always use _'--filter=...'_ option.

```bash
$ /server/scripts/backup/restore.sh --filter=christ
```

This should show something like this so you can choose the file you want to restore:

```bash
[...]

>>> ------------------------------------------------------------------
>>>
>>>[WARNING] Cleaning up all files at restore stage folder... (/server/backup/restore)
>>>
>>> ------------------------------------------------------------------

[start]---------------------------------------------------------------
...running function "select_file" to:
-----------------------------------------------------

Select one of the files below:

   christforyou.info-20200720_011900.tar.gz

```

> **[IMPORTANT]** If the site you are restoring is already running you will be prompted to check if you want to continue, then if you want to backup the running site before continue.


2. Restore from backup storage

```bash
$ /server/scripts/backup/restore.sh --filter=christ --from-storage
```

3. Restoring to a new site url

When you have a site backup and need to convert the backup site to a **new url**, example, you backup the site _christforyou.info_ and want to restore this site to a new url so you can get a similar site under the url _christforall.biblemission.digital_ then should use _'--new-url'_ option. The [Clone Script](/clone) uses this logic as well.

```bash
$ /server/scripts/backup/restore.sh --filter=christ --new-url=christforall.biblemission.digital --backup-if-running
```

If the site _'christforall.biblemission.digital'_ is already running in the server it will backup and set the tag _-auto-backup-restore-script_ added to the backup file, which should look like something like this:

```bash
ls -lah /server/backup/sites/

drwxrwxr-x+ 2 evert evert 4.0K Jul 20 02:12 .
drwxrwxr-x+ 7 evert evert 4.0K Jul  7 09:33 ..
-rw-rw-r--+ 1 root  root   33M Jul 20 01:19 christforyou.info-digital-auto-backup-restore-script-20200720_022500.tar.gz
```

### Cleanup script (_cleanup.sh_)

Now we should do some cleaning! This script will help cleanup unwanted backup files _locally_ or in the _backup server_.

Here is the _helper_ for this script:

```bash
$ /server/scripts/backup/cleanup.sh -h

Usage:
    cleanup.sh [-d destination_folder]
              [-u site_url | --filter="string"]
              [--clean-storage]
              [--local-only] [--storage-only]
              [--all-sites] [--backup-id=20200720_030845]
              [--yes]
              [--debug] [--silent]

    Required
        There are no required parameter, but you could use the options below
    in order to automate your action.

    Alternatively you may inform the options below
    -d | --destination  Location to your BACKUP files
    -u | --url          Site URL that should be listed
    --filter=""         The same as above (-u "string")
    --backup-id         The backup identification
                        [IMPORTANT] This backup id will delete the specific
                        file with this id. The default id value is
                        'YearMonthDay_HourMinuteSeconds'
    --all--sites        This option will clean backup files for all sites in your
                        destination folder
    --local-only        Clean backup file only locally
    --clean-storage     Clean backup file on the backup storage
    --storage-only      Clean files ONLY  in the backup storage. This option only
                        works when --local-only is NOT set.
    --yes               Set "yes" to all, use it with caution
    --debug             Show all steps of the script execution
    --silent            Hide all message
    -h | --help         Display this help
```

And again... the options should _speak_ for themselves... but I know, I really know that we can never think of everything! Here are the basics:

1. Running the script

This script is a _multiselect_ option, so multiple files can be deleted at once. We always suggest you to use _'--filter=...'_ to list only files related to your request.

```bash
$ /server/scripts/backup/cleanup.sh --filter=christ
```

The output will be somethint like this:

```bash
[...]

>>> ------------------------------------------------------------------
>>>
>>>[WARNING] Select all files you want to delete.
>>>
>>> ------------------------------------------------------------------

[start]---------------------------------------------------------------
...running function "select_multiple_data" to:
-----------------------------------------------------

Avaliable options:

  1) christforyou.info-20200720_011900.tar.gz
  2) christforyou.info-20200720_025742.tar.gz
Check an option (again to uncheck, ENTER when done):

```

1.1 Seleting the files to be deleted

All files selected will be deleted and you `can not` restore. So make sure you to double check before confirming your action.

In the example above when you type number '1' and press _Enter_ you will have the following:

```bash
[start]---------------------------------------------------------------
...running function "select_multiple_data" to:
-----------------------------------------------------

Avaliable options:

  1) christforyou.info-20200720_011900.tar.gz
  2) christforyou.info-20200720_025742.tar.gz
Check an option (again to uncheck, ENTER when done): 1
-----------------------------------------------------

Avaliable options:

  1+) christforyou.info-20200720_011900.tar.gz
  2) christforyou.info-20200720_025742.tar.gz
christforyou.info-20200720_011900.tar.gz was checked
Check an option (again to uncheck, ENTER when done):

```

Please note that you have a _plus sign_ added to the number 1 and in the terminal it will be in different color (green) as well, so you know for sure what is seleted. Also you have the message _'christforyou.info-20200720_011900.tar.gz was checked'_. Press _Enter_ again and confirm your action.

This will prompt you a message if you want to cleanup the backup storage as well (if there is a file with the same name in the backup storage). If you want to consider 'yes to all' add the option _'--yes'_ as in restore o backup script.

2. Cleaning up backup storage

In order to **list** file from the backup storage you must use _'--storage-only'_.

```bash
$ /server/scripts/backup/cleanup.sh --filter=christ --storage-only
```

You probably will be prompted with many more options than running locally, once there is a backup routine that sends backup files to the storage.

```bash
[...]

Connected to bmbackup.
>>> ------------------------------------------------------------------
>>>
>>>[WARNING] Select all files you want to delete.
>>>
>>> ------------------------------------------------------------------

[start]---------------------------------------------------------------
...running function "select_multiple_data" to:
-----------------------------------------------------

Avaliable options:

  1) christforyou.info-20200605_094838.tar.gz
  2) christforyou.info-20200605_130854.tar.gz
  3) christforyou.info-20200612_130210.tar.gz
  4) christforyou.info-20200625_105004.tar.gz
  5) christforyou.info-20200626.tar.gz
  6) christforyou.info-20200629_024647.tar.gz
  7) christforyou.info-20200703.tar.gz
  8) christforyou.info-20200710.tar.gz
  9) christforyou.info-20200717.tar.gz
Check an option (again to uncheck, ENTER when done):

```

Here you should select all files you want to delete from the storage. Make sure you keep at least a couple backups from the sites.

3. Cleanup all backup files :fearful:

Yes... I know, it looks scary... but notice the important thing, it will delete ALL backup files with an specific id, which means if you have in the storage many files you have set with id of '-20200717', so you will have this tag for all sites running in the server. How to accomplish that? It´s easy, you run the following:

```bash
$ /server/scripts/backup/cleanup.sh --all-sites --backup-id="20200717" --storage-only
```

This will clean up all files with the tag _'-20200717'_ from the backup storage. So if you have all files below at the backup storage, all of them will be deleted:

```bash
$ /server/scripts/backup/cleanup.sh --filter=20200717 --storage-only

[...]

Avaliable options:

  1) bibel-mission.de-20200717.tar.gz
  2) biblemission.by-20200717.tar.gz
  3) biblemission.kz-20200717.tar.gz
  4) biblemission.md-20200717.tar.gz
  5) biblemission.org.ua-20200717.tar.gz
  6) biblemission.ru-20200717.tar.gz
  7) biblemissionglobal.org-20200717.tar.gz
  8) biblemissions.org-20200717.tar.gz
  9) bmcanada.org-20200717.tar.gz
 10) bmslavic.org-20200717.tar.gz
 11) christforyou.info-20200717.tar.gz
 12) course222.biblemission.digital-20200717.tar.gz
 13) detskoesluzhenie.org-20200717.tar.gz
 14) kapai.biblemission.digital-20200717.tar.gz
 15) omsk.biblemission.ru-20200717.tar.gz
 16) sofiachurch.biblemission.digital-20200717.tar.gz
Check an option (again to uncheck, ENTER when done):

```

---

I think this is it! We might update this docs as soon as some new feature pop's up!
