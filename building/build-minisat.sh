#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds minisat as a statically linked binary

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="minisat"
declare -r TOOL_URL="https://github.com/niklasso/minisat.git"


# declare a suffix for the binary
declare -r BUILD_SUFFIX="_static"

# the final binary should be moved here
SCRIPT_DIR=$(dirname "$0")
declare -r BINARY_DIRECTORY="$(readlink -e "$SCRIPT_DIR")/binaries"

# commit we might want to build, defaults to empty, if none is specified
declare -r COMMIT=${MINISAT_COMMIT:-}

# specific instructions to build the tool: minisat
# this function is called in the source directory of the tool
build_tool ()
{
	make r -j $(nproc) RELEASE_LDFLAGS=-static

	# check file properties
	file build/release/bin/minisat
	# make executable for everybody
        chmod oug+rwx build/release/bin/minisat
	# store created binary in destination directory, with given suffix
	cp build/release/bin/minisat "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"
}

#
# this part of the script should be rather independent of the actual tool
#

# build the tool
build()
{
	pushd "$TOOL"
	build_tool
	popd
}

# get the tool via the given URL
get()
{
	# get the solver, store in directory "$TOOL"
	if [ ! -d "$TOOL" ]
	then
		git clone "$TOOL_URL" "$TOOL"
	fi

	# in case there is a specific commit, jump to this commit
	if [ -n "$COMMIT" ]
	then
		pushd "$TOOL"
		git fetch origin
		git reset --hard "$COMMIT"
		# no submodules are used in minisat
		popd
	fi
}


mkdir -p "$BINARY_DIRECTORY"
get
build
