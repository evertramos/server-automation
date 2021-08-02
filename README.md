# Server Automation 🔥

Scripts to automate your work and give you more time for your family! 
(That was my main purpose, reason why I believe it would be useful for some other folks)

> 🚧 This is a _work in progress_ project 

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
 - [ ] 
 - [ ] 
 - [ ] 



## How to use it?

Well, this repo is probably cloned to our server... it should be located at `/server/script' folder, but if you don´t find it in our server, please follow up our [Script Instalation Wiki](../wikis/Initial-Setup).


#### References

https://www.gnu.org/software/bash/manual/
