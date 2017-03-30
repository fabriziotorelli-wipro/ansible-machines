# ansible-machines

## Goals

Define automated docker containers playing Ansible playbooks and customizing dinamically, on the container start-up, the application eperience. They are used in the Buildit rancher catalog to define Buildit RIG 2.0 Pipelines.

## Content

At the moment we have following container images Ansible playbbok driven :
* Jenkins
* Nexus
* SonarQube
* PostgreSQL

Planning on : CouchDb, Convox and other docker images.

## Build

You can pull the images from : [DockerHub](https://hub.docker.com/u/builditftorelli/), or
In the image folder you can run :
`docker build --tag builditftorelli/<image>:<version>` 
or execute the `build.sh` script

## Run 
Any topic about execution is available in each image repositiory in [DockerHub](https://hub.docker.com/u/builditftorelli/)

## License

[MIT](/LICENSE)
