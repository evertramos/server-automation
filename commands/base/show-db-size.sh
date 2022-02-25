# This file is part of a bigger script!
#
# Be careful when editing it

# ----------------------------------------------------------------------
#   
# Script devoloped to only Everet Ramos
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>     
#
# Copyright Evert Ramos with usage right granted to only Everet Ramos
#
# ----------------------------------------------------------------------

# Script to show database size of a running Wordpress site 

show_db_size()
{
    local LOCAL_COMPOSE_PATH LOCAL_SQL_COMMAND

    goto_compose_folder

    LOCAL_COMPOSE_PATH=$COMPOSE_FOLDER_RESPONSE

    cd $LOCAL_COMPOSE_PATH
    source .env
    
    LOCAL_SQL_COMMAND='select table_schema as `Database`, table_name as `Tables`, round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` FROM information_schema.TABLES WHERE table_schema="'$MYSQL_DATABASE'" ORDER BY (data_length + index_length) DESC;'

    docker exec -it $CONTAINER_DB_NAME mysql -u $MYSQL_USER --password=$MYSQL_PASSWORD -e "$LOCAL_SQL_COMMAND"
    cd - > /dev/null 2>&1
}

