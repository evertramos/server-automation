# server-automation
Scripts to automate your work! (bash script, docker, docker-compose, dns etc)

> These scripts were meant to do one thing and do it good!

# @todo

- check domain exist and dns is forwarding before run the new site script, if create/set dns continue...
- www option on start

----


Scripts developed to make your life easier!

> Some of the scripts are still under development. Use with caution.

## How to use it?

Well, this repo is probably cloned to our server... it should be located at `/server/script' folder, but if you don´t find it in our server, please follow up our [Script Instalation Wiki](../wikis/Initial-Setup).

## Roadmap

## 1. Clone scripts

_Clone scripts_ will allow you to duplicate ("clone") a running site (the whole environment) to a new domain, with all files cloned exact the same way you had in the _original_ site.

[Link to documentation](./clone/README.md)

## 2. Backup scripts

The _backup scripts_ was designed to run a complete **backup**, **restore** and backup **cleanup**. Please check each feature in details in our [Wiki](../wikis/scripts/backup)

[Link to documentation](./backup/README.md)

## 3. Plugin WP script

This script is meant to install plugins in a running Wordpress.

[Link to documentation](./plugin-install-wp/README.md)

## 4. Start new WP script

This script is meant to start new site using the standards of these scripts.

[Link to documentation](./start-new-wp-site/README.md)
