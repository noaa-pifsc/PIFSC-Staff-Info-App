# Staff Directory Project
The Staff Directory Project is a CentOS 7 Docker container with Apache, Perl and Oracle connection drivers hosting a set of dynamic Perl scripts that serve dynamic staff directory contents.

## System Requirements
The following packages should be installed on the host operating system:

* `docker`
* `docker-compose`
* Production: `journald`

## Image Details
The Docker image is built from the official CentOS 7 Docker image. Apache, Perl, Oracle drivers and Oracle CPAN modules are installed on top of the base operating system.

The image has been configured to write both `access.log` and `error.log` to `/dev/stdout` and `/dev/stderr` respectively to prevent the container from growing in size from traffic logs.

In production, the image will write to `journald` and in development it will write to a local `json` file and rotate logs automatically.

## Development
The application files can be edited outside of the Docker container but to run Docker in a development environment use the following commands and edit the files on the host operating system which is mounted to a volume inside the container. This will start the container with the settings in `docker-compose.yml`.

#### Start docker-compose environment
* Active console output: `docker-compose up`
* Run as daemon: `docker-compose -d`

#### Stop docker-compose environment
* `docker-compose down`

## Build
To build a version of this image for production use or commiting to a registry run the following command.

* `docker-compose -f docker-compose.yml -f docker-compose.prod.yml build`

**NOTE:** This is not required for the current solution as the image alone is not being transferred between machines or pushed to a Docker registry. The image will be built at deployment time as detailed in the following _Deployment_ section.

## Deployment
To deploy to a production environment the following steps should be taken.

**NOTE:** The port that will be mapped to on the production server is defined in `docker-compose.prod.yml` and is recommended to be edited before the following steps but can also be modified on the host operating system prior to starting the `docker-compose up` command. The internal container port `80` should not be changed in the following declaration:

```
 ports:
      - "5000:80"
```

1. Create a `.tar.gz` archive containing the entire contents of the project directory
    * Ex. `tar zcvf staff-directory.tar.gz .`
2. Copy the `staff-directory.tar.gz` to destination server.
3. Extract archive in location of choice on destination server
    * `cd /some/project/path/`
    * `tar xvf staff-directory.tar.gz`
    * `cd staff-directory`
    * `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`
4. Site will now be accessible on the IP of the host and the port specified in `docker-compose.prod.yml`

**NOTE:** All access logs will be written to `journald` and can be accessed via `journalctl` on the host operating system.
