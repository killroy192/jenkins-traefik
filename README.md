# Bootstrap for Jenkins

Unofficial bootstrap for running your own [Jenkins](https://jenkins.io/) with [Docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/).

## Requirements

 * Docker 17.05.0+
 * Compose 1.17.0+
 * Traefik should be running with predefined network

## Setup

To get started with all the defaults, simply clone the repo and run `./install.sh` in your local check-out.

The recommended way to customize your configuration is using the files below, in that order:

 * `.env`
 * `config/env/jenkins.env` w/ environment variables

## Updating Sentry

Just use the following steps to update:
```sh
docker-compose build --pull # Build the services again after updating, and make sure we're up to date on patch version
docker-compose up -d # Recreate the services
```