# A simple Docker image for CKAN
This is a very simple and easy to use docker image for CKAN

## Usage

```sh
cd /opt
sudo mkdir ckan
cd ckan
sudo mkdir config
sudo mkdir log
sudo mkdir plugins
sudo mkdir postgresql
sudo mkdir solr
sudo mkdir storage
sudo wget https://raw.githubusercontent.com/qlands/ckan_docker/main/example_docker_compose/docker-compose.yml
sudo docker-compose up -d
# CKAN will run in http://localhost:5000
```

## Customization of environmental variables

- ckan_user: This is the CKAN role name in postgresql. Use a name without spaces.
- ckan_database: This is the name of the CKAN database in postgresql.  Use a name without spaces.
- ckan_password: This is the password for the CKAN role in postgresql. Do not use @ in the password.
- ckan_admin: This is the CKAN System Administrator user. Use a name without spaces.
- ckan_admin_name: This is the CKAN System Administrator name. Use the same as ckan_admin or a name without spaces.
- ckan_admin_email: This is the CKAN System Administrator email.
- ckan_admin_password: This This is the CKAN System Administrator password. Do not use @ in the password. **It must be at least 8 characters long**.
- ckan_site_url: This final site URL. For example: https://ckan.mysite.com

## Current CKAN image

The latest image TAG in DockerHub is 020905 (CKAN 2.9.5) (1.75 GB) using Ubuntu 20.04
