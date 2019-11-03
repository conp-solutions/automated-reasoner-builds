#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds z3 as a statically linked binary

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="z3"
declare -r TOOL_URL="https://github.com/Z3Prover/z3.git"


# declare a suffix for the binary
declare -r BUILD_SUFFIX="_static"

# the final binary should be moved here
SCRIPT_DIR=$(dirname "$0")
declare -r BINARY_DIRECTORY="$(readlink -e "$SCRIPT_DIR")/binaries"

# commit we might want to build, defaults to empty, if none is specified
declare -r COMMIT=${Z3_COMMIT:-}

# specific instructions to build the tool: z3
# this function is called in the source directory of the tool
build_tool ()
{
	# configure to build a statically linked binary
	python scripts/mk_make.py --staticbin CXX=g++
	cd build/
	make -j $(nproc)

	# check file properties
	file z3
	# make executable for everybody
        chmod oug+rwx z3
	# store created binary in destination directory, with given suffix
	cp z3 "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"
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
		# no submodules are used in z3
		popd
	fi
}


mkdir -p "$BINARY_DIRECTORY"
get
build
