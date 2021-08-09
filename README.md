# Server Automation 🚀

Scripts to automate your daily work in bash scripting!️

> 🚧 This is a _work in progress_ project 

## Video Tutorials (will be recorded soon!)

[![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCN5wb0eA3ZLlvJNYo23qBRQ)

## How to start 🔰
[![shell script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://github.com/evertramos)

1. Make sure NGINX Proxy is running

Please check [NGINX Proxy Automation](https://github.com/evertramos/nginx-proxy-automation) for more details.

> You will need the proxy running to run some scripts in this project

2. Clone this repository using the option **_--recurse-submodules_** ⚠

```bash
git clone --recurse-submodules https://github.com/evertramos/server-automation server-automation 
```

We use [**basescript**](https://github.com/evertramos/basescript) 🛰

3. Create .env file

```bash
cd server-automation && cp .env.example .env
```

> Make sure your file path where you cloned this project (item 2) and proxy (item 1) are correct. 

4. Start new site!

Go to wordpress folder, create .env file and run new site script!

```bash
cd wordpress && cp .env.example .env && ./new-site.sh --new-url PUT_HERE_YOUR_DOMAIN.com --disable-letsencrypt --skip-docker-image-check
```

> In this item we will use [Docker WordPress](https://github.com/evertramos/docker-wordpress) version number 'v0.6' for now.

> If you want to have **Lets Encrypt** running, please inform the correct email address in _./server-automation/wordpress/.env_ file
> and remove _--disable-letsencrypt_ option from the line above. 

## **Done!** 🏁

Check the domain in the browser and install your new WordPress site! 

> Your domain url, used in the option _--new-url_ above, must have the DNS correctly pointing to your server.

## Contribute

[![image](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/evertramos)
[![image](https://img.shields.io/badge/picpay-21C25E?style=for-the-badge&logo=picpay&logoColor=white)](https://picpay.me/evert.ramos)



