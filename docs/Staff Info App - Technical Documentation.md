# Staff Information App Technical Documentation

## Overview
The Staff Information Application (SIA) is a web app that provides access to the PIFSC Oracle personnel database for information that does not contain sensitive information or PII.  There are two web pages; one provides a sortable tabular staff directory listing and the other shows a formatted organization hierarchy chart.  The web app is implemented as a docker container.  

## Resources
-   Version Control Information:
    -   URL: https://picgitlab.nmfs.local/omi-apps/staff-directory.git
    -   Application: 1.2 (Git tag: staff_info_app_v1.2)
-   [End-User Documentation](./docs/Staff%20Info%20App%20-%20End-User%20Documentation.md)

## Application Access
-   \*Note: by default the staff directory web page is loaded when the application URLs are loaded
-   Development: https://picapps-dev.nmfs.local/staff-directory/
-   Test: https://picapps-test.nmfs.local/staff-directory/
-   Production: https://picapps.nmfs.local/staff-directory/

## Requirements
-   System:
    -   Docker
        - Apache 2.x, PHP 8.x
-   User:
    -   Any modern web browser
    -   PIFSC network connection 

## Dependencies
-   The SIA utilizes the [PHP Shared Library](https://picgitlab.nmfs.local/centralized-data-tools/php-shared-library) for Oracle database interactions

## Docker Image Details
The Docker image is built from the official Oracle InstantClient on OracleLinux 8 [Docker image](https://github.com/oracle/docker-images/blob/main/OracleInstantClient/oraclelinux8/21/Dockerfile). Apache and PHP are installed on the base image.

## Implementation
-   There are two PHP pages that are accessed directly via web browser, one for the staff directory ([staff-directory.php](../src/staff-directory.php)) and one for the organization chart ([org-chart.php](../src/org-chart.php))
-   ### Shared Elements
    -   There is a navigation menu at the top of both web pages that provides links to the two pages, the link for the current page is grayed out and the corresponding link is not enabled
-   ### Staff Directory
    -   The staff directory displays all current PIFSC personnel in a table with several columns of information.  Each column heading is implemented as a link that provides sorting capabilities with the appropriate icons showing the current sort order for the column (if any) or if there is no sorting applied to the given column it is shown with a general sort icon.  
    -   Email and phone numbers are implemented as links.
-   ### Organization Chart
    -   This web page displays all of the current PIFSC personnel in a hierarchical diagram using HTML and css
    -   The Directors Office is shown at the top of the page 
        -   The Divisions are shown below along with all Subdivisions, Programs and Subprograms nested below the corresponding Divisions.  
    -   Each individual is shown below their corresponding organizational unit with their abbreviated position with indicators based on their employer (e.g. (c) for contractors, (CI) for cooperative institute employees)
    -   Features:
        -   Tooltips are implemented for all personnel.  When a given person's email or phone numbers are stored in the database, links for each are available in the tooltip.  

## Repository Folder Structure
-   The [httpd](../docker/config/httpd) folder contains the Apache configuration 
-   The [php](../docker/config/php) folder contains the PHP configuration 
-   The [deployment_scripts](../docker/deployment_scripts) folder contains scripts to prepare and deploy the docker project
-   The [docs](../docs) folder contains documentation for the project
-   The [src](../src) folder contains all source code for the project
-   The [backend](../src/backend) folder contains backend PHP include files for the project
-   The [frontend](../src/frontend) folder contains the PHP web pages that are directly requested via web browser
    -   The [img](../src/frontend/img) folder contains the client-side images used in the web pages
    -   The [js](../src/frontend/js) folder contains the client-side JavaScript code used in the web pages
    -   The [style](../src/frontend/style) folder contains the client-side css used in the web pages
    -   The [webfonts](../src/frontend/webfonts) folder contains the client-side web fonts used by the css in the web pages
-   #### Repository Folder Diagram:
    ```
    .
    |--- docker
    |    |--- docker-compose.yml
    |    |--- Dockerfile
    |    |--- config
    |    |    |--- httpd
    |    |    |--- php
    |    |--- deployment_scripts
    |--- docs
    |--- src 
    |    |--- backend
    |    |    |--- *.php
    |    |--- frontend
    |    |    |--- *.php
    |    |    |--- img
    |    |    |--- js
    |    |    |--- style
    |    |    |--- webfonts
    ```

## Setup
-   ### Docker Application Setup
    -   \*Note: the steps shown here were developed and tested on a Windows computer
    -   #### Project Preparation
        -   \*Note: the reason there is a project preparation step is to omit unnecessary files/folders from the docker container and from the docker host the docker container is deployed to
        -   Clone the [SIA repository](https://picgitlab.nmfs.local/omi-apps/staff-info-app) on the docker host where the container will be deployed
        -   Open the [project_config.sh](./docker/deployment_scripts/sh_script_config/project_config.sh) and set the $root_directory to an appropriate folder path on the computer you are using.
        -   Run the project preparation script ([prepare_docker_project.sh](./docker/deployment_scripts/prepare_docker_project.sh)) to generate a preparation folder based on the $project_folder variable with the code for the corresponding application instance.
            -   The script will clone the SIA and PHP Shared Library repositories in the tmp/ subdirectory of the specified preparation folder and copy the files from each repository to the appropriate folders in the preparation folder.  
            -   Once the project folder is prepared the tmp/ folder will be deleted
        -   ### Prepared Project Folder
            -   Open the credentials file (backend/staff-info-app/db_credentials.php) in the preparation folder and specify the database connection information for the database instance the given application will use
            -   When the docker project is prepared it will copy files/folders from the repository folder structure to the appropriate locations in the docker folder structure:
                -   #### PHP Shared Library:
                    -   The backend PHP shared library .php files needed for oracle database interactions are copied to backend/php-shared-library folder
                -   #### SIA:
                    -   The backend SIA .php files are copied from the [backend](../src/backend) repository folder to backend/staff-info-app folder in the prepared project folder structure
                    -   The frontend SIA .php files are copied from the [frontent](../src/frontend) repository folder to the www folder in the prepared project folder structure
                    -   The frontend SIA client-side folders/files are copied from the [frontent](../src/frontend) repository folder to the corresponding www folder's subdirectories in the prepared project folder structure
                    -   The [deployment_scripts](../docker/deployment_scripts) repository folder/files are copied to the deployment_scripts folder in the prepared project folder structure
                    -   The [config](../docker/config) repository folder/files are copied to the config folder in the prepared project folder structure
        -   #### Prepared Folder Diagram:
            ```
            .
            |--- backend
            |    |--- staff-info-app
            |    |--- php-shared-library
            |--- config
            |    |--- httpd
            |    |--- php
            |--- deployment_scripts
            |--- www 
            |    |--- img
            |    |--- js
            |    |--- style
            |    |--- webfonts
            |    |--- *.php
            ```
    -   #### Docker Deployment
        -   #### Docker folder structure
            -   When the docker image is built and the container is run it will copy files from the prepared directory into the docker container:
                -   The www preparation folder is copied to the /var/www/html folder in the docker container
                -   The backend preparation folder is copied to the /usr/src/app folder in the docker container
                -   The config/httpd/*.conf preparation folder files are copied to the /etc/httpd/conf.d folder in the docker container to specify Apache configuration options
                -   The config/php/*.ini preparation folder files are copied to the /etc/php.d folder in the docker container to specify PHP configuration options
        -   #### Docker Folder Diagram:
            ```
            .
            |--- /var/www/html
            |    |--- img
            |    |--- js
            |    |--- style
            |    |--- webfonts
            |    |--- *.php
            |--- /usr/src/app
            |    |--- staff-info-app
            |    |--- php-shared-library
            |--- /etc/php.d
            |--- /etc/httpd/conf.d
            ```
        -   ##### Local Docker Desktop
            -   Execute the deployment_scripts/build_deploy_project.sh script in the prepared project folder to build and run the docker container
        -   ##### Docker Host Server (via PuTTY)
            -   Open Pageant
                -   Click "Add CAPI Cert" and choose your CAC credentials
            -   Open PuTTY
                -   login to the specific docker host with your CAC username
                -   Make the temporary directory used to transfer files and grant permissions to read the directory by executing the following commands
                    ```
                    mkdir /tmp/staff-info-app
                    chmod -R 755 /tmp/staff-info-app
                    ```
            -   Open a Command Prompt and change to the prepared folder
                -   Recursively copy the prepared folder contents using the following command (where  [server host] is the hostname/IP address of the docker host server):
                    ```
                    pscp -r ./ [username]@[server host]:/tmp/staff-info-app/
                    ```
            -   In PuTTY, run the following commands to move the prepared files into the specified directory on the docker host server:
                ```
                # switch to the directory containing the prepared folder contents
                cd /tmp/staff-info-app

                # update the permissions on the prepared folder's files
                chmod -R 755 *

                # switch to the docker user
                sudo su - docker-user

                # create the target docker folder where [container folder] is the name of the folder where the docker container will be run from
                mkdir containers/[container folder]

                # switch to the target docker folder where the docker container will be run from
                cd containers/[container folder]

                # shutdown the container (if it is already running)
                docker compose down

                # remove any source files from the target directory:
                rm -rf *

                # copy the files from the prepared folder to the
                rsync -aP /tmp/staff-info-app/* .

                # build and run the container:
                docker compose -f docker-compose.yml up -d  --build

                # revert to user account
                exit

                # cleanup the container source files in the temporary directory
                rm -rf /tmp/staff-info-app
                ```

## Security Features
-   Global Security Features:
    -   SQL queries use prepared statements and bind variables to prevent SQL Injection Attacks
    -   Database values are sanitized using [htmlspecialchars()](https://www.php.net/manual/en/function.htmlspecialchars.php) before being included in the HTML web page content to prevent Cross Site Scripting (XSS) attacks
-   Organization Chart:
    -   Tooltip content is retrieved from the database and stored in a javascript array of objects, when a given tooltip is activated the content in the corresponding object variable is sanitized before it is displayed
-   Staff Directory:
    -   User Input for links (used in sorting functionality) is validated against a list of acceptable values and if there 