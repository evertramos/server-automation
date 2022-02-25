# Clone Script

Now you have the option to clone running site into new urls in a few steps. Check it out!

### Requirements

1. You must have the settle the BM Script into the server ([Initial Setup](wikis/initial-setup)). 

### How to use (basic)

Just as simple as:

1. Enter the clone script folder and run it! :thumbsup:

```bash
$ cd /server/script/clone

$ ./clone.sh
```

2. Select the site you wish to clone

You will be prompted to select which site you wish to clone:

![Clone Script - Select Site](images/clone_select_site.png "Clone Script - Select Site")

3. Inform the new url for the cloned site

![Clone Script - Inform New URL](images/clone_inform_new_url.png "Clone Script - Inform New URL")

In the example above we informed "clone.biblemission.digital" as a test.

> You can have only one clone per URL. If there the URL you have informed is already running on the server the script will fail and inform you on the screen.


**Wait until it finishes the cloning process. Depending on the size of the website it will take longer to copy all files, update the database with new url and start the new site (cloned).

### Advanced usage

There is a helper you may check befores running the script in advanced mode:

```bash
$ ./clone_wp.sh -h

Usage:
    clone.sh [-nu your_new_url.com] [-u your_site_url]
                 [-s source_folder] [-d destination_folder]
                 [--no-start] [--wp-debug] [--debug] [--silent]

    Or use long options:
    clone.sh [--new-url=your_new_url.com] [--url=your_site_url]
                 [--source=source_folder] [--destination=destination_folder]
                 [--no-start] [--wp-debug] [--debug] [--silent]

    Alternatively you may inform the options below
    -nu | --new-url         The new URL for the clone site
    -u  | --url             The new url for the cloning site
    -s  | --source          Folder where the docker-compose.yml for the running site is located
    -d  | --destination     Folder where the clone site will be located
    -h  | --help            Display this help
    --no-start              Clone the site but does not start the docker-compose services
                            [WARNING!] Careful when cloning sites with the same URL.
                            It is recommended you ALWAYS USE the --new-url option.

    There is some debug options you may use in order to hide or show more details
    --wp-debug              Turn WP_DEBUG option to true on wp-config file
    --debug                 Show script debug options
    --silent                Hide all script message
```

```bash
$ ./clone_wp.sh -nu myclone.biblemission.digital
```

> The clone URL must be unique, otherwise the script will fail and inform you on the screen.

If you are interested in automate or even run the script without the user interaction, you may use the URL option (-u) as of below:

```bash
$ ./clone_wp.sh -u bmcanada.org -nu clonebmcanada.biblemission.digital
```

Or even add the `--silent` option at the end, so no message will be outputed.
