#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds mergesat as a statically linked binary

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="muser2"
declare -r TOOL_URL="https://bitbucket.org/anton_belov/muser2.git"


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
	cd ./src/tools/muser2
	make -j $(nproc)

	# check file properties
	file muser2
	# make executable for everybody
        chmod oug+rwx muser2
	# store created binary in destination directory, with given suffix
	cp muser2 "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"
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


#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds muser2

# in case something goes wrong, notify!
set -ex

build_muser2()
{
	pushd muser2
	cd ./src/tools/muser2
	make -j 4
	file muser2
        chmod oug+rwx muser2
	cp muser2 ../../../../muser2_glibc
	popd
}

# get muser2
get_muser2()
{
	if [ ! -d muser2 ]
	then
		git clone https://bitbucket.org/anton_belov/muser2.git
	fi
}

get_muser2
build_muser2
