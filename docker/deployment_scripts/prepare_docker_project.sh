#! /bin/sh

# deployment script
echo "running Staff Directory deployment script"

# load the project configuration script to set the runtime variable values
. ./sh_script_config/project_config.sh

project_folder="staff-info-app"

project_folder_path="$project_directory/$project_folder"

mkdir $root_directory/docker
mkdir $project_folder_path
mkdir $project_folder_path/tmp


echo "create the web folder structure"
mkdir $project_folder_path/www

echo "create the backend folder structure"
mkdir $project_folder_path/backend
mkdir $project_folder_path/backend/$project_folder
mkdir $project_folder_path/backend/php-shared-library




echo "clone the project dependencies"

git clone $php_lib_git_url $project_folder_path/tmp/php-shared-library


# copy the php-shared-library (oracle .php files only)
echo "copy the php-shared-library backend directory"
cp -r $project_folder_path/tmp/php-shared-library/oracle*.php  $project_folder_path/backend/php-shared-library

echo "clone the project repository"

#checkout the git projects into the same temporary docker directory
git clone $sia_git_url $project_folder_path/tmp/$project_folder

echo "copy source code/docker files"
cp -R $project_folder_path/tmp/$project_folder/docker/* $project_folder_path

# copy the source files to the www directory:
cp -R $project_folder_path/tmp/$project_folder/src/frontend/* $project_folder_path/www 

# copy the backend source files to the backend/$project_folder directory:
cp -R $project_folder_path/tmp/$project_folder/src/backend/* $project_folder_path/backend/$project_folder

# rename the db_credentials.template.php to the active db_credentials.php file
mv $project_folder_path/backend/$project_folder/db_credentials.template.php $project_folder_path/backend/$project_folder/db_credentials.php

# remove the working directories where the files in the export folder were prepared from
echo "remove all temporary files"
rm -rf $project_folder_path/tmp

echo "the docker project files are now ready for configuration and image building/deployment"

read
