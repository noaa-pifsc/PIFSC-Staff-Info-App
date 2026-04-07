# Staff Information App Technical Documentation

## Overview
The Staff Information Application (SIA) is a web app that provides access to the PIFSC Oracle personnel database for information that does not contain sensitive information or PII.  There are two web pages; one provides a sortable tabular staff directory listing and the other shows a formatted organization hierarchy chart.  The web app is implemented as a docker container.  

## Resources
-   Version Control Information:
    -   URL: https://picgitlab.nmfs.local/omi-apps/staff-directory.git
    -   Application: 1.3 (Git tag: staff_info_app_v1.3)
-   [End-User Documentation](./Staff%20Info%20App%20-%20End-User%20Documentation.md)
-   [Container Application Deployment (CAD) process documentation](../container_application_deployment/Container%20Application%20Deployment%20Process.md)

## Application Access
-   Development: https://picapps-dev.nmfs.local/staff-directory/
-   Test: https://picapps-test.nmfs.local/staff-directory/
-   Production: https://picapps.nmfs.local/staff-directory/

## Requirements
-   Docker Host
    -   Docker
        -   Docker host and reverse proxy configured to allow web requests to the container host via port 80 to the web application on port 5006
    -   Docker secrets
    -   git
    -   dos2unix
-   Client Machine (for deployments)
    -   OpenSSH is setup to work with CAC authentication
    -   OpenSSH is configured to specify the username in the ~/.ssh/config file for each container host (e.g. pifsc-dev-docker-01-as for the dev container host)
        -   The ForwardAgent feature is enabled to allow the git repositories to be cloned on the container host
-   User:
    -   Any modern web browser
    -   PIFSC network connection 

## Database Instances
-   For the development container and database instances the abbreviation used is "dev" 
-   For the test/QA container and database instances the abbreviation used is "test" 
-   For the production container and database instances the abbreviation used is "prod" 

## Dependencies
-   The SIA utilizes the [PHP Shared Library](https://picgitlab.nmfs.local/centralized-data-tools/php-shared-library) for Oracle database interactions
    -   This is implemented in the repository as a git submodule stored in the [php-shared-library](../modules/php-shared-library) folder
    -   This application was developed with version 1.17 (tag: php_shared_libary_v1.17) of the PHP Shared Library
-   The PRI utilizes the [CAD](https://github.com/noaa-pifsc/PIFSC-Container-Application-Deployments) for automated container deployments
    -   folder path: [modules/CAD](../modules/CAD)
    -   URL: <git@github.com:noaa-pifsc/PIFSC-Container-Application-Deployments.git>

## Container Image Details
The container image is built from the official Oracle InstantClient on OracleLinux 8 [Docker image](https://github.com/oracle/docker-images/blob/main/OracleInstantClient/oraclelinux8/21/Dockerfile). Apache and PHP are installed on the base image.

## Implementation
-   There are two PHP pages that are accessed directly via web browser, one for the staff directory ([staff-directory.php](../src/frontend/staff-directory.php)) and one for the organization chart ([org-chart.php](../src/frontend/org-chart.php))
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
-   \*Note: See [CAD Repository Folder Structure](../container_application_deployment/Container%20Application%20Deployment%20Process.md#project-specific-cad-folder-structure) for information about the standard project-specific CAD folder structure
-   The [container_application_deployment](../container_application_deployment) folder contains all files used directly in the CAD implementation
    -   [docker-compose.yml](../container_application_deployment/docker-compose.yml) is the configuration file used for container swarm deployments
    -   [docker-compose.local.dev.yml](../container_application_deployment/docker-compose.local.dev.yml) is the configuration file used for local container compose deployments
    -   [Dockerfile](Dockerfile) defines the resources used in the PRI container image
    -   The [config](../container_application_deployment/config) folder contains the container configuration files 
        -   The [httpd](../container_application_deployment/config/httpd) folder contains the Apache configuration 
        -   The [php](../container_application_deployment/config/php) folder contains the PHP configuration 
-   The [src](../src) folder contains all source code for the project
    -   The [backend](../src/backend) folder contains backend PHP include files for the project
    -   The [frontend](../src/frontend) folder contains the PHP web pages that are directly requested via web browser
        -   The [img](../src/frontend/img) folder contains the client-side images used in the web pages
        -   The [js](../src/frontend/js) folder contains the client-side JavaScript code used in the web pages
        -   The [style](../src/frontend/style) folder contains the client-side css used in the web pages
        -   The [webfonts](../src/frontend/webfonts) folder contains the client-side web fonts used by the css in the web pages
-   The [docs](../docs) folder contains documentation for the project
-   #### Repository Folder Diagram:
    ```
    .
    |--- container_application_deployment
    |    |--- docker-compose.local.dev.yml
    |    |--- docker-compose.yml
    |    |--- Dockerfile
    |    |--- config
    |    |    |--- httpd
    |    |    |--- php
    |--- docs
    |--- modules
    |    |--- CAD
    |    |--- php-shared-library
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

## Project-Specific CAD Implementation
-   Refer to the [CAD Implementation Procedure](../container_application_deployment/docs/Container%20Application%20Deployment%20Process.md#cad-implementation-procedure) documentation for custom project-specific CAD files

## Setup:
-   Refer to [PRI Container Application Deployment Process - Setup Documentation](../container_application_deployment/Container%20Application%20Deployment%20Process.md#setup) for CAD setup details

## Executing the CAD Script
-   To deploy the container application, refer to the [Executing the CAD Script](../container_application_deployment/docs/Container%20Application%20Deployment%20Process.md#executing-the-cad-script) documentation

## Container Folder Structure
-   The container folder structure closely mirrors the [Repository Folder Structure](#repository-folder-structure) except for a few notable differences:
    -   The /var/www/html folder is populated with the contents of the [frontend](../src/frontend) folder from the repository
    -   The /usr/src/app folder is populated with the contents of the [backend](../src/backend) folder from the repository
    -   The /etc/php.d folder is populated with the contents of the [php](../container_application_deployment/config/php) folder from the repository
    -   The /etc/httpd/conf.d folder is populated with the contents of the [php](../container_application_deployment/config/httpd) folder from the repository
-   ### Container Folder Diagram
    ```
    .
    |--- /var/www/html
    |    |--- img
    |    |--- js
    |    |--- style
    |    |--- webfonts
    |    |--- *.php
    |--- /usr/src/app
    |    |--- *.php
    |    |--- dependencies
    |    |    |--- *.php
    |--- /etc/php.d
    |--- /etc/httpd/conf.d
    ```

## Security Features
-   Global Security Features:
    -   SQL queries use prepared statements and bind variables to prevent SQL Injection Attacks
    -   Database values are sanitized using [htmlspecialchars()](https://www.php.net/manual/en/function.htmlspecialchars.php) before being included in the HTML web page content to prevent Cross Site Scripting (XSS) attacks
    -   Database credentials are managed within the docker swarm using docker secrets to help ensure the credentials are secured against unauthorized access
    -   Refer to [CAD Security Features](../container_application_deployment/docs/Container%20Application%20Deployment%20Process.md#security-features)
-   Organization Chart:
    -   Tooltip content is retrieved from the database and stored in a javascript array of objects, when a given tooltip is activated the content in the corresponding object variable is sanitized before it is displayed
-   Staff Directory:
    -   User Input for links (used in sorting functionality) is validated against a list of acceptable values and if it does not match it will display a generic error to the user