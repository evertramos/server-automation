# SSH Scripts 🔥

Oh yeah!

You can let someone access a container in your environment in, I would say, a "safe mode"! 
Using something like a _bastion host_, or we might call _bastion container_.

Here we have multiple scripts for the SSH services in our server. 
Please be very careful when using this script once the user added will have access to site container with root access.

## It would look like this:  

@todo - image!

## Requirements

- You must have the a **ssh-manager** container running ([SSH-MANAGER](https://github.com/evertramos/docker-ssh-bastion)). 

## How to use

### 1. Add new user

To add a new user to the ssh-manager container you must use a ssh-key.... 

Just as simple as:

1. Enter the script folder and run:

```bash
$ ./add-user.sh -u user_name -s container-name-where-user-will-have-access -k "asdfasdfasdfasdfasdf"
```

🏄 You can try now to access using the private key you have provided.

#### Delete a user

1. Enter the script folder and run:

```bash
$ cd /server/script/ssh

$ ./deleteuser.sh
```

#### Grant access to internal containers

1. Enter the script folder and run:

```bash
$ cd /server/script/ssh

$ ./grantuseraccess.sh
```

#### Revoking user access to a containers

1. Enter the script folder and run:

```bash
$ cd /server/script/ssh

$ ./revokeuseraccess.sh
```

### Important information

When running the scripts above you might be prompted with the follow screen to choose MORE THAN ONE option:

![Multi Select - Select container(s)](images/multi_select_container.png "Multi Select - Select container(s)")

**Select Option** - You should type the number corresponding to the options you want to choose and hit _ENTER_. You will notice that it will add a 'plus sign' and change colors when you have selected an option.

**Remove Option** - In order to remove option you type the number of a selected object and hit _ENTER_. You will notice that the 'plus sign' will be gone and color will be back to default.

After you have selected all options you want, you hit _ENTER_ with empty option and it will continue the script execution.

Here is an example of selected options:

![Multi Select - Selected container(s)](images/multi_select_selected_containers.png "Multi Select - Selected container(s)")

#### Helpers

In all scripts you can check the helpers for more automation:

.. include:: localscript/usage-adduser.sh
   :literal:

```bash
$ ./adduser.sh -h

LOCAL FILE

Usage:
    adduser.sh   [-c container_name     | --container=container_name        ]
                 [-u user_name          | --user-name=user_name             ]
                 [-k "key_string"       | --key-string="key_string"         ]
                 [-f /path/to/key_file  | --key-file=/path/to/key_file      ]
                 [-s site_container     | --site-container=site_cotainer    ]
                 [--add-user-only] [--debug] [--silent]

    Alternatively you may inform the options below
    -c | --container        The SSH container name (default: 'ssh')
    -u | --user-name        User name that should be created in 'ssh' cotnainer
    -k | --key-string       The ssh pub key string (IN ONE LINE)
    -f | --key-file         The ssh pub key file (ex. id_rsa.pub)
    -s | --site-container   The container name that 'user' shall have access to
                            [IMPORTANT] You may add multiple sites using the '-s'
                            option:
                                ... -s container_1 -s container_2 -s container_3
                            If you do not inform this option you will be prompted
                            to select the containers
    --add-user-only         This option will only add a user to the 'ssh' container
                            and will not prompt you to grant access to this 'user'
                            into to site's containers

    There is some debug options you may use in order to hide or show more details
    --debug                 Show script debug options
    --silent                Hide all script message
```