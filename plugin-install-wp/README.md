# Plugin Install Script

This script is meant to install plugin, or a list of plugin for a domain to an specific destination

## How to use

[![Video](http://img.youtube.com/vi/TbPqIxvuk7c/0.jpg)](https://www.youtube.com/watch?v=TbPqIxvuk7c "Plugin Install")

Video: https://www.youtube.com/watch?v=TbPqIxvuk7c

> In order to run this plugin script you must have sudo right and NOPASSWD set in the sudoers config.

After cloning this repo you should follow the steps below:

1. Configure your *.env* file

1.1 Copy the file .env.example to .env 
```bash
$ cp .env.exempla .env
```

1.2 Set your site and backup folder, as of:
```bash
$ vi .env

SITES_FOLDER=/server/sites

```

2. Set your plugins you will install in a text file (no extention, txt, md etc)

```bash
$ echo "jetpack" > /server/plugin/list1
$ echo "jetpack" >> /server/plugin/list1
$ echo "bbpress" >> /server/plugin/list1
```

3. Run the plugin script

Before you run the plugin script you could check the helper:

```bash
$ ./plugin_install_wp.sh -h
Usage:
    plugin_install_wp.sh -u your_site_url [-s plugig_list_folder] [-d site_folder]
                                  [-f plugin_list_file_name] [-g git_repo]
                                  [--debug] [--silent] [--start]

    Required
    -u | --url                  Site url that should be located in the 'SITES_FOLDER'
                                configures in your .env file.
                                The folder name must match with the site url,
                                otherwise please use -s option.
    -s | --source               Folder where your the plugin file list is located
                                or inform the file name option (-f)
                                or inform the file git repo option (-g)

    Alternatively you may inform the options below
    -d | --destination          Folder where your sites is located
    -f | --file                 The file with a list of plugins
                                [IMPORTANT] The list should be set in the file with
                                line break.
    -g | --git-repo             Git repo that contains the WordPress Plugin
                                [IMPORTANT] If your git repo is private you must set your
                                credentials or set a ssh key to your git repo.
    --activate                  Activate the plugin when installing

    There is some debug options you may use in order to hide or show more details
    --debug                     Show all steps of the script execution
    --silent                    Hide all message
    -h | --help                 Display this help
```

**You must inform at least the Site URL and the source folder (or file name, or the git repo) to run the plugin script.**

Using the URL and Source option:
```bash
$ ./plugin_install_wp.sh -u bmcanada.org -s /server/plugins --debug
```

Using the URL and Git option:
```bash
$ ./plugin_install_wp.sh -u bmcanada.org -g https://git.biblemission.me/wordpress-plugins/bm-user-dashboard --debug
```

Specify the plugin list file:
```bash
$ ./plugin_install_wp.sh -u bmcanada.org -f /server/plugins/list1 --debug
```

Specify the activate option:
```bash
$ ./plugin_install_wp.sh -u bmcanada.org -s /server/plugins --activate --debug
```

## Output messages

The regular output for the backup process should look like the following:

```bash
[start]--------------------------------------------------
...running function "check_docker" to:
Check if 'docker' is installed and running.
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_local_env_file" to:
Check if '.env' file is set.
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_running_script" to:
Check if there is another instance of the script running...
pid: /server/scripts/plugin-wp/.backup_script.pid
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_folder_exists" to:
Checking if folder /server/sites/ramos.biblemission.digital exists.
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_compose_up" to:
Checking if the services/cotnainers are up and running for this folder: [/server/sites/ramos.biblemission.digital/compose]
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "check_folder_exists" to:
Checking if folder /server/scripts/plugin-wp/files/ exists.
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "select_file" to:
There are multiple files with this domain. Now you will need to select which file you want to restore.
-----------------------------------------------------

Select one of the files you have in your backup folder:

   list1
   list2.txt
   list3.md

You have selected the file: list1

-----------------------------------------------------
>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "install_plugins" to:
Installing plugins list from list1

>>> Installing the plugin: jetpack
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: jetpack: Plugin already installed.
<<< end [jetpack]

>>> Installing the plugin: bbpress
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: bbpress: Plugin already installed.
<<< end [bbpress]

>>> Installing the plugin: gone
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: gone: Plugin not found.
<<< end [gone]

>>> Installing the plugin: akismet
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: akismet: Plugin already installed.
<<< end [akismet]

>>> Success!
[end]----------------------------------------------------

[start]--------------------------------------------------
...running function "activate_plugins" to:
Installing plugins list from list1

>>> Activating plugin: jetpack
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: Plugin 'jetpack' is already active.
<<< end [jetpack]

>>> Activating plugin: bbpress
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: Plugin 'bbpress' is already active.
<<< end [bbpress]

>>> Activating plugin: gone
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: The 'gone' plugin could not be found.
<<< end [gone]

>>> Activating plugin: akismet
WARNING: Found orphan containers [...]
Starting ramos-db ... done
Warning: Plugin 'akismet' is already active.
<<< end [akismet]

>>> Success!
[end]----------------------------------------------------

>>> -----------------------------------------------------
>>>
>>> [ATTENTION] Here is a list of the plugins in your file: [jetpack bbpress gone akismet]
>>>
>>> -----------------------------------------------------
```

> It is a little long... but it shows you all message. If there is any plugin that was not found in the Wordpress site it will NOT stop the script. It will show you that a message that it does not exist the plugin.

## Warnings

There are some warnings you might receive from the docker that you don´t need to worry about, such as:

```bash
WARNING: Found orphan containers (bmomsk-site, sofiachurch-site, bmde-site, bmglobal-site, bms-db, bmde-db, bmkz-db, bms-site, bmkz-site, clone-db-bmde, bmby-site, det-db, evert-db, canadabm-db, bmmd-site, bmglobal-db, bmua-db, bmru-site, sofiachurch-db, bmru-db, det-site, bmmd-db, kapai-site, evert-site, bmslavic-site, bmomsk-db, canadabm, clone-site-bmde, bmua-site, kapai-db, bmby-db, bmslavic-db) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up
```

This warning just show you that you have more containers than you are starting the new docker-compose file.
