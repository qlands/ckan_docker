#!/bin/bash

if [ "$(ls -A /var/lib/postgresql/12/main)" ]; then
    export new_installation=0
else
    export new_installation=1
    cd /var/lib/postgresql/12/main
    unzip /postgresql.zip
    cd ..
    chown -R postgres main
    chgrp -R postgres main
    chmod -R 0750 main

    cd /var/lib/solr/data
    unzip /solr.zip
    cd ..
    chown -R jetty data
    chgrp -R jetty data
    chgrp root data
fi
/etc/init.d/redis-server start
/etc/init.d/postgresql start
/etc/init.d/jetty9 start

if [ "$new_installation" == 1 ]; then
    sed -i 's@tmp_role@'"$ckan_user"'@' /create_role.sql
    sed -i 's@tmp_pass@'"$ckan_password"'@' /create_role.sql
    su - postgres -c 'psql -f /create_role.sql'

    sed -i 's@tmp_role@'"$ckan_user"'@' /create_database.sh
    sed -i 's@tmp_database@'"$ckan_database"'@' /create_database.sh

    /create_database.sh

    source /opt/ckan/bin/activate
    ckan generate config /opt/ckan/config/ckan.ini

    sed -i 's@ckan_default:pass@'"$ckan_user":"$ckan_password"'@' /opt/ckan/config/ckan.ini
    sed -i 's@localhost/ckan_default@'localhost/"$ckan_database"'@' /opt/ckan/config/ckan.ini
    sed -i 's@ckan.site_url =@'"ckan.site_url = $ckan_site_url"'@' /opt/ckan/config/ckan.ini
    sed -i 's@8983@'8080'@' /opt/ckan/config/ckan.ini
    sed -i 's@#solr_url@'solr_url'@' /opt/ckan/config/ckan.ini
    sed -i 's@#ckan.redis.url@'ckan.redis.url'@' /opt/ckan/config/ckan.ini
    sed -i 's@#ckan.storage_path = /var/lib/ckan@'"ckan.storage_path = /opt/ckan/storage"'@' /opt/ckan/config/ckan.ini
    sed -i 's@ckan.display_timezone = server@'"ckan.display_timezone = UTC"'@' /opt/ckan/config/ckan.ini

    ln -s /opt/ckan/src/ckan/who.ini /opt/ckan/config/who.ini
    ckan -c /opt/ckan/config/ckan.ini db init

    cp /wsgi.py /opt/ckan/config
    cp /start_ckan.sh /opt/ckan/config
    cp /stop_ckan.sh /opt/ckan/config
    chmod +x /opt/ckan/config/start_ckan.sh
    chmod +x /opt/ckan/config//stop_ckan.sh

    sed -i 's@tmp_admin@'"$ckan_admin"'@' /create_sysadmin.sh
    sed -i 's|tmp_email|'"$ckan_admin_email"'|' /create_sysadmin.sh
    sed -i 's@tmp_name@'"$ckan_admin_name"'@' /create_sysadmin.sh
    sed -i 's@tmp_password@'"$ckan_admin_password"'@' /create_sysadmin.sh
    /create_sysadmin.sh

    deactivate
fi

source /opt/ckan/bin/activate
ckan -c /opt/ckan/config/ckan.ini db upgrade
cd /opt/ckan/config
./start_ckan.sh

set -e

tail -f /dev/null
