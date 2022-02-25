## Project roadmap 🛣 
 - [X] Start new WordPress site
 - [X] Add ssh support for containers (ssh-bastion)
 - [ ] Script to configure .env file for the server-automation
 - [ ] Script to configure .env file for the wordpress functions
 - [ ] Install docker
 - [ ] Prepare folder structure with correct permissions of the folder
 - [ ] Add ftp support for WordPress containers
 - [ ] Backup docker containers (files and structures)
 - [ ] Backup in external server
 - [ ] Cleanup backup files (local and external)
 - [ ] Backup WordPress files and databases (volumes + dump?)
 - [ ] Clone WordPress site (*****)
 - [ ] Restore WordPress site from Clone (copy) 
 - [ ] Restore WordPress site from Backup
 - [ ] Update WordPress version in a running container  
 - [ ] Install WordPress plugins in a running container
 - [ ] Configure DNS (Amazon + Digital Ocean + CloudFlare)
 - [ ] Configure .env for server-automation *automatically*
 - [ ] Start log system for server
 - [ ] Test whole suite in Ubuntu, Debian and CentOS
 - [ ] Create test case
 - [ ] Configure github action to test all scripts
 
> This is a few ideas but not necessary in this order! 

> Let's share some ideias in [Github Discussions](https://github.com/evertramos/server-automation/discussions)

### Reminders

- Check usage of '~' for home folder, some path will not accept it, make sure user will not use it when it is not able to
