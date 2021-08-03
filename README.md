# Server Automation 🔥

Scripts to automate your daily work in bash scripting! 🛩️

> 🚧 This is a _work in progress_ project 

## Video Tutorials

[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCN5wb0eA3ZLlvJNYo23qBRQ)

## TL;DR 🦥

Add _basescript_ to your scripts will give you a bunch of functions with nice results. Check our boilerplate script:

whole and reuse functions designed to get the results you expect. Such as, replace string in a file, or replace only variable value in a file (ex. .env or .yml files). For a few more information you might want to check out YouTube Channel.



## 

## Requirements (@todo)

- bash
- sudo
- sed
- awk

## Main Functions

### WordPress scripts

1. New site (./wordpress/new-site.sh)

This script will start a new WordPress site using this repo:

https://github.com/evertramos/docker-wordpress

Please check all the options available in the helper (`$ ./new-site.sh -h`) or access:

[Link to WordPress scripts documentation](./wordpress/README.md)

## TODO

- não permitir usar '~' para a pasta home
- create info instead of warning for some cases such as success
- inserir success message at the end of wordpress new site
- script to create .env in wordpress (skip-exit option)
- script to create .env in server-automation (skip-exit option)

## Roadmap 
 - [X] Start new WordPress site
 - [X] Add ssh support for containers (ssh-bastion)
 - [ ] Install docker
 - [ ] Prepare folder structure with correct permissions of the folder
 - [ ] Add ftp support for containers
 - [ ] Backup docker containers (files)
 - [ ] Backup in external server
 - [ ] Cleanup backup files
 - [ ] Backup WordPress files and databases (volumes + dump)
 - [ ] Clone WordPress site
 - [ ] Restore WordPress site from Clone (copy) 
 - [ ] Restore WordPress site from Backup
 - [ ] Update WordPress version in running container  
 - [ ] Install WordPress plugins in running container
 - [ ] Configure DNS (Amazon + Digital Ocean)
 - [ ] Configure .env for server-automation *automatically*
 - [ ] Start log system for server
 - [ ] Test whole suite in Ubuntu, Debian and CentOS
 - [ ] 
 - [ ] 



## How to use it?

Well, this repo is probably cloned to our server... it should be located at `/server/script' folder, but if you don´t find it in our server, please follow up our [Script Instalation Wiki](../wikis/Initial-Setup).

#### References

https://www.gnu.org/software/bash/manual/

## Contribute

[![image](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/evertramos)
[![image](https://img.shields.io/badge/picpay-21C25E?style=for-the-badge&logo=picpay&logoColor=white)](https://picpay.me/evert.ramos)



