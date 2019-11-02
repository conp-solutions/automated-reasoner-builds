#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds all available tools, or the specified target (via the
# environment variable DOCKER_BUILD_TARGET).

set -xe

# check whether we should only build one target
BUILD_TARGET="${DOCKER_BUILD_TARGET:-}"

# make sure we work in the directory this script resides in
SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=$(readlink -e "$SCRIPT_DIR")
cd "$SCRIPT_DIR"

# select the dockerfile to be used for building all tools
# default to the provided one, based on Ubuntu 16.04
if [ -n "${BUILD_DOCKERFILE:-}" ]
then
	DOCKERFILE="$(readlink -e "$BUILD_DOCKERFILE")"
else
	DOCKERFILE="$SCRIPT_DIR"/../dockerfiles/Dockerfile-BuildSolvers-Ubuntu-16.04
fi

# check if build target is present, if selected
if [ -n "$BUILD_TARGET" ] && [ ! -x "./build-$BUILD_TARGET.sh" ]
then
	echo "error: specified build script ./build-$BUILD_TARGET.sh is not available"
	exit 1
fi

# overall return code
declare -i OVERALL_STATUS=0

# make sure we can write logs
mkdir -p build-logs

# build all targets that we have, jump over this script
for NEXT in ./build-*.sh
do
	# make sure we do not call ourselves
	[ "$NEXT" != "./build-tools.sh" ] || continue

	# only execute execuatble scripts
	[ -x "$NEXT" ] || continue

	# build the next target, if we did not select one
	if [ -z "$BUILD_TARGET" ] || [ "./build-$BUILD_TARGET.sh" == "$NEXT" ]
	then
		echo "[$SECONDS] start building $NEXT"
		mkdir -p "$SCRIPT_DIR"/build-logs
		declare -i STATUS=0
		"$SCRIPT_DIR"/../scripts/run_in_container.sh \
			"$SCRIPT_DIR"/../dockerfiles/Dockerfile-BuildSolvers-Ubuntu-16.04 \
			"$NEXT" &> "$SCRIPT_DIR"/build-logs/$NEXT.build.log || STATUS=$?
		[ "$STATUS" -eq 0 ] || OVERALL_STATUS=$STATUS
		echo "[$SECONDS] finished building $NEXT with status $STATUS (see "$SCRIPT_DIR"/build-logs/$NEXT.build.log)"
	fi
done

# exit with the collected exit code
exit $OVERALL_STATUS
