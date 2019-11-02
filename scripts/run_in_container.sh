#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019

# Run commands inside container

set -ex
DOCKERFILE="$1"  # Dockerfile
shift

USER_FLAGS="-e USER="$(id -u)" -u=$(id -u)"

# disable getting the source again
if [ -z "$1" ] || [ "$1" = "sudo" ]
then
	USER_FLAGS=""
	shift
fi

if [ ! -r "$DOCKERFILE" ]
then
	echo "cannot find $DOCKERFILE (in $(readlink -e .)), abort"
	exit 1
fi

# get information for docker container ubild
DOCKERFILE_DIR=$(dirname "$DOCKERFILE")
CONTAINER="${CONTAINER:-}"
[ -n "$CONTAINER" ] || CONTAINER=$(docker build -q -f "$DOCKERFILE" "$DOCKERFILE_DIR")

# execute in the container we just build, keep the container around (no --rm)
echo "running in container: $CONTAINER"
docker run \
  -it \
  --rm \
  $USER_FLAGS \
  -v $PWD:$PWD \
  -w $(pwd) \
  "$CONTAINER" "$@"
