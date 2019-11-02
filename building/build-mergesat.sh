#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds mergesat as a statically linked binary

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="mergesat"
declare -r TOOL_URL="https://github.com/conp-solutions/mergesat.git"


# declare a suffix for the binary
declare -r BUILD_SUFFIX="_static"

# the final binary should be moved here
SCRIPT_DIR=$(dirname "$0")
declare -r BINARY_DIRECTORY="$(readlink -e "$SCRIPT_DIR")/binaries"

# commit we might want to build, defaults to empty, if none is specified
declare -r COMMIT=${MERGESAT_COMMIT:-}

# specific instructions to build the tool: mergesat
# this function is called in the source directory of the tool
build_tool ()
{
	# enter simp directory and build
	cd minisat/simp
	# build a statically linked binary, build everything again
	make rs -j $(nproc) -B

	# check file properties
	file mergesat_static
	# make executable for everybody
        chmod oug+rwx mergesat_static
	# store created binary in destination directory, with given suffix
	cp mergesat_static "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"
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
		# no submodules are used in mergesat
		popd
	fi
}


mkdir -p "$BINARY_DIRECTORY"
get
build