#! /bin/sh

# deployment script
echo "running Staff Directory deployment script"

# load the project configuration script to set the runtime variable values
. ./sh_script_config/project_config.sh

# create the temporary folder that the repos will be copied to
mkdir -p $project_folder_path/tmp

echo "create the web folder structure"
mkdir $project_folder_path/www

echo "create the backend folder structure"
mkdir -p $project_folder_path/backend/$sia_project_folder
mkdir $project_folder_path/backend/$shared_library_folder


echo "clone the project dependencies"

git clone $php_lib_git_url $project_folder_path/tmp/$shared_library_folder


# copy the php-shared-library (oracle .php files only)
echo "copy the php-shared-library backend directory"
cp -r $project_folder_path/tmp/php-shared-library/oracle*.php  $project_folder_path/backend/$shared_library_folder


# remove the working directories where the files in the export folder were prepared from
echo "remove all temporary files"
rm -rf $project_folder_path/tmp

echo "copy source code/docker files for the SIA from the current repo"

## copy the files in the docker directory
cp -R ../* $project_folder_path

## remove the unnecessary deployment_scripts files
rm -rf $project_folder_path/deployment_scripts/sh_script_config
rm $project_folder_path/deployment_scripts/prepare_docker_project.sh

# copy the source files to the www directory:
cp -R ../../src/frontend/* $project_folder_path/www 

# copy the backend source files to the backend/$project_folder directory:
cp -R ../../src/backend/* $project_folder_path/backend/$sia_project_folder

# rename the db_credentials.template.php to the active db_credentials.php file
mv $project_folder_path/backend/$sia_project_folder/db_credentials.template.php $project_folder_path/backend/$sia_project_folder/db_credentials.php

echo "the docker project files are now ready for configuration and image building/deployment"