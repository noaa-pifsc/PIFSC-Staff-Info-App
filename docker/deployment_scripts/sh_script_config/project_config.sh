# define the staff info app git url
sia_git_url="--branch branch_v1.2 https://picgitlab.nmfs.local/omi-apps/staff-info-app.git"

# define the project folder name
sia_project_folder="staff-info-app"

# define the PHP shared library git url
php_lib_git_url="--branch branch_v1.16 https://picgitlab.nmfs.local/centralized-data-tools/php-shared-library.git"

# shared library folder name
shared_library_folder="php-shared-library"

# define the project folder path where the prepared project files will be located (next to the project repository in the docker_projects folder)
project_folder_path="../../../docker_projects/$sia_project_folder"
