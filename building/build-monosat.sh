#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds monosat as a statically linked binary

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="monosat"
declare -r TOOL_URL="https://github.com/sambayless/monosat.git"


# declare a suffix for the binary
declare -r BUILD_SUFFIX="_static"

# the final binary should be moved here
SCRIPT_DIR=$(dirname "$0")
declare -r BINARY_DIRECTORY="$(readlink -e "$SCRIPT_DIR")/binaries"

# commit we might want to build, defaults to empty, if none is specified
declare -r COMMIT=${MONOSAT_COMMIT:-}

# specific instructions to build the tool: monosat
# this function is called in the source directory of the tool
build_tool ()
{
	mkdir -p bin

	# fake a statically-linking g++
	cat << 'EOF' > bin/c++
/usr/bin/c++ "$@" -static
EOF
	chmod uog+x bin/c++
	export PATH=$(readlink -e bin):$PATH

	# configure static build
	cmake . -DBUILD_STATIC=ON -DBUILD_DYNAMIC=OFF -DCMAKE_CXX_COMPILER=c++
	# build, for now using 1 core due to high memory consumption
	make -j 1

	# repeat last step of compilation one more time, reorder some parameter to make it actually a statically linked binary
	c++ -DNO_GMP -std=c++11 -Werror=return-type -Wno-unused-variable -Wno-unused-but-set-variable   -Wno-sign-compare  -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -O3 -DNDEBUG -DNDEBUG -O3  -rdynamic CMakeFiles/monosat_static.dir/src/monosat/Main.cc.o  -o monosat -static libmonosat.a -lz -lgmpxx -lgmp

	# check file properties
	file monosat
	# make executable for everybody
        chmod oug+rwx monosat
	# store created binary in destination directory, with given suffix
	cp monosat "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"
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
		# no submodules are used in monosat
		popd
	fi
}


mkdir -p "$BINARY_DIRECTORY"
get
build
