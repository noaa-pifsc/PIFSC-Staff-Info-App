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

echo "clone the project repository"

#checkout the git projects into the same temporary docker directory
git clone $sd_git_url $project_folder_path/tmp/staff-directory

echo "copy docker files"
cp $project_folder_path/tmp/staff-directory/docker/config/ $project_folder_path

# copy the source files to the src directory:
cp -R $project_folder_path/tmp/staff-directory/src $project_folder_path 

# copy all the docker files to the $project_folder_path
cp -R $project_folder_path/tmp/staff-directory/docker/* $project_folder_path/

# remove the unnecessary dockerfile and .yml files
rm -rf $project_folder_path/config


# rename the db_credentials.template.php to the active db_credentials.php file
mv $project_folder_path/src/includes/db_credentials.template.php $project_folder_path/src/includes/db_credentials.php

# move the includes files out of the web root folder
mv $project_folder_path/src/includes $project_folder_path/includes

# remove the working directories where the files in the export folder were prepared from
echo "remove all temporary files"
rm -rf $project_folder_path/tmp

echo "the docker project files are now ready for configuration and image building/deployment"

read
