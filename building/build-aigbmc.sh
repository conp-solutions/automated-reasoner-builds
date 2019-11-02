#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds aigbmc as a statically linked binary

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="aigbmc"
declare -r TOOL_URL=""  # does not come with git repository (yet?)


# declare a suffix for the binary
declare -r BUILD_SUFFIX="_static"

# the final binary should be moved here
SCRIPT_DIR=$(dirname "$0")
declare -r BINARY_DIRECTORY="$(readlink -e "$SCRIPT_DIR")/binaries"

# commit we might want to build, defaults to empty, if none is specified
declare -r COMMIT=${AIGBMC_COMMIT:-}

# specific instructions to build the tool: aigbmc
# this function is called in the source directory of the tool
build_tool ()
{
	# build picosat
	pushd picosat
	./configure.sh
	make -j $(nproc)
	popd

	# build lingeling
	pushd lingeling
	./configure.sh
	make -j $(nproc)
	popd

	# build aiger-1.9.9
	pushd aiger-1.9.9
	./configure.sh
	make aigbmc -j $(nproc) CFLAGS=-static

	# check file properties
	file aigbmc
	# make executable for everybody
        chmod oug+rwx aigbmc
	# store created binary in destination directory, with given suffix
	cp aigbmc "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"
	popd
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
		mkdir -p "$TOOL"
		pushd "$TOOL"

		# get actual aiger package
		wget http://fmv.jku.at/aiger/aiger-1.9.9.tar.gz
		tar xzf aiger-1.9.9.tar.gz
		rm -rf aiger-1.9.9.tar.gz

		# get SAT backends
		git clone https://github.com/arminbiere/lingeling.git  # we will use lingeling as SAT backend
		wget http://fmv.jku.at/picosat/picosat-965.tar.gz  # picosat is required to build successfully
		tar xzf picosat-965.tar.gz
		rm -f picosat-965.tar.gz
		ln -sf picosat-965 picosat
		popd
	fi

	# in case there is a specific commit, jump to this commit
	if [ -n "$COMMIT" ]
	then
		pushd "$TOOL"
		git fetch origin
		git reset --hard "$COMMIT"
		# no submodules are used in aigbmc
		popd
	fi
}


mkdir -p "$BINARY_DIRECTORY"
get
build
