#!/usr/bin/env bash
set -e

MIN_DOCKER_VERSION='17.05.0'
MIN_COMPOSE_VERSION='1.17.0'
JENKINS_ENV_FILE='config/env/jenkins.env'
ENV_FILE='.env'
DOCKER_VERSION=$(docker version --format '{{.Server.Version}}')
COMPOSE_VERSION=$(docker-compose --version | sed 's/docker-compose version \(.\{1,\}\),.*/\1/')

DID_CLEAN_UP=0

ver () { echo "$@" | awk -F. '{ printf("%d%03d%03d", $1,$2,$3); }'; }

make_env() {
    if [ -f "$@" ]; then
        echo "$@ already exists, skipped creation."
    else
        echo "Creating $@..."
        cp -n "$@.example" "$@"
    fi   
}

# the cleanup function will be the exit point
cleanup() {
  if [ "$DID_CLEAN_UP" -eq 1 ]; then
    return 0;
  fi
  echo "Cleaning up..."
  docker-compose down &> /dev/null
  DID_CLEAN_UP=1
}

trap cleanup INT TERM

echo "Checking minimum requirements..."

if [ $(ver $DOCKER_VERSION) -lt $(ver $MIN_DOCKER_VERSION) ]; then
    echo "FAIL: Expected minimum Docker version to be $MIN_DOCKER_VERSION but found $DOCKER_VERSION"
    exit -1
fi

if [ $(ver $COMPOSE_VERSION) -lt $(ver $MIN_COMPOSE_VERSION) ]; then
    echo "FAIL: Expected minimum docker-compose version to be $MIN_COMPOSE_VERSION but found $COMPOSE_VERSION"
    exit -1
fi

echo ""
echo "prepearing envs"
make_env $JENKINS_ENV_FILE
make_env $ENV_FILE
echo ""

echo ""
echo "Creating volumes for persistent storage..."
echo "Created $(docker volume create --name=jenkins-home)."
echo ""

echo ""
echo "Building and tagging Docker images..."
echo ""
docker-compose build
echo ""
echo "Docker images built."

cleanup

echo ""
echo "----------------"
echo "You're all done! Run the following command get initial jenkins pass:"
echo ""
echo " docker exec jenkins_worker cat var/jenkins_home/secrets/initialAdminPassword"
echo ""
