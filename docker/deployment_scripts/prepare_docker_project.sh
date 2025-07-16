#! /bin/sh

# deployment script
echo "running Staff Directory deployment script"

# load the project configuration script to set the runtime variable values
. ./sh_script_config/project_config.sh

project_folder="staff-directory"

project_folder_path="$project_directory/$project_folder"

mkdir $root_directory/docker
mkdir $project_folder_path
mkdir $project_folder_path/tmp


echo "create the web folder structure"
mkdir $project_folder_path/www
mkdir $project_folder_path/www/php-shared-library
mkdir $project_folder_path/www/php-shared-library/css
mkdir $project_folder_path/www/php-shared-library/js
mkdir $project_folder_path/www/php-shared-library/img

echo "create the backend folder structure"
mkdir $project_folder_path/backend
mkdir $project_folder_path/backend/staff-directory
mkdir $project_folder_path/backend/php-shared-library




echo "clone the project dependencies"

git clone $php_lib_git_url $project_folder_path/tmp/php-shared-library


# copy the php-shared-library (.php and .inc files only)
echo "copy the php-shared-library backend directory"
cp -r $project_folder_path/tmp/php-shared-library/*.php  $project_folder_path/backend/php-shared-library
cp -r $project_folder_path/tmp/php-shared-library/*.inc  $project_folder_path/backend/php-shared-library

# copy the php-shared library client-side files
echo "copy the php-shared-library client-side directory"
cp -r $project_folder_path/tmp/php-shared-library/css/*  $project_folder_path/www/php-shared-library/css
cp -r $project_folder_path/tmp/php-shared-library/js/*  $project_folder_path/www/php-shared-library/js
cp -r $project_folder_path/tmp/php-shared-library/img/*  $project_folder_path/www/php-shared-library/img



echo "clone the project repository"

#checkout the git projects into the same temporary docker directory
git clone $sd_git_url $project_folder_path/tmp/staff-directory

echo "copy source code/docker files"
cp -R $project_folder_path/tmp/staff-directory/docker/ $project_folder_path

# copy the source files to the www directory:
cp -R $project_folder_path/tmp/staff-directory/src/ $project_folder_path/www 

# remove the unnecessary dockerfile and .yml files
rm -rf $project_folder_path/config


# rename the db_credentials.template.php to the active db_credentials.php file
mv $project_folder_path/src/includes/db_credentials.template.php $project_folder_path/src/includes/db_credentials.php

# move the includes files out of the web root folder
mv $project_folder_path/www/includes/* $project_folder_path/backend/staff-directory

# remove the includes subfolder
rmdir $project_folder_path/www/includes/










# remove the working directories where the files in the export folder were prepared from
echo "remove all temporary files"
# rm -rf $project_folder_path/tmp

echo "the docker project files are now ready for configuration and image building/deployment"

read
