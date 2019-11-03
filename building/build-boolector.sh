#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script builds boolector as a statically linked binary
# This script produces 2 tools, boolector and btormc

# in case something goes wrong, notify!
set -ex

# name of the tool we build
declare -r TOOL="boolector"
declare -r TOOL_URL="https://github.com/Boolector/boolector.git"


# declare a suffix for the binary
declare -r BUILD_SUFFIX="_static"

# the final binary should be moved here
SCRIPT_DIR=$(dirname "$0")
declare -r BINARY_DIRECTORY="$(readlink -e "$SCRIPT_DIR")/binaries"

# commit we might want to build, defaults to empty, if none is specified
declare -r COMMIT=${BOOLECTOR_COMMIT:-}

# specific instructions to build the tool: boolector
# this function is called in the source directory of the tool
build_tool ()
{
	# get one line scan, to force -static as compilation argument
	[ -d one-line-scan ] || git clone https://github.com/awslabs/one-line-scan.git
	ONE_LINE_SCAN=$(readlink -e one-line-scan/one-line-scan)

	# get tools required to build boolector
	./contrib/setup-lingeling.sh
	./contrib/setup-cadical.sh
	./contrib/setup-btor2tools.sh

	# configure, using the compiler provided by one-line-scan
	"$ONE_LINE_SCAN" -j $(nproc) \
		--extra-cflags -static \
		--no-gotocc \
		--plain -o PLAIN --use-existing -- \
		./configure.sh

	# build, using the one-line-scan compiler again, which enforces -static
	cd build
	"$ONE_LINE_SCAN" -j $(nproc) \
		--extra-cflags -static \
		--no-gotocc \
		--plain -o PLAIN --use-existing -- \
		make -j $(nproc)

	# check file properties
	file bin/boolector
	# make executable for everybody
        chmod oug+rwx bin/boolector
	# store created binary in destination directory, with given suffix
	cp bin/boolector "$BINARY_DIRECTORY"/"${TOOL}${BUILD_SUFFIX}"

	# do the same for btormc
	# check file properties
	file bin/btormc
	# make executable for everybody
        chmod oug+rwx bin/btormc
	# store created binary in destination directory, with given suffix
	cp bin/btormc "$BINARY_DIRECTORY"/"btormc${BUILD_SUFFIX}"
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
		# no submodules are used in boolector
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
# This script builds Boolector

# In case something goes wrong, notify!
set -ex

build_boolector()
{
	pushd boolector

	# clean
	rm -rf build/*

	# get tools required to build boolector
	./contrib/setup-lingeling.sh
	./contrib/setup-cadical.sh
	./contrib/setup-btor2tools.sh

	# configure
	"$ONE_LINE_SCAN" -j $(nproc) \
		--extra-cflags -static \
		--no-gotocc \
		--plain -o PLAIN --use-existing -- \
		./configure.sh

	# build
	cd build
	"$ONE_LINE_SCAN" -j $(nproc) \
		--extra-cflags -static \
		--no-gotocc \
		--plain -o PLAIN --use-existing -- \
		make -j $(nproc)

	popd
}

# get minisat as one SAT solver to show case
get_boolector()
{
	if [ ! -d boolector ]
	then
		git clone https://github.com/Boolector/boolector.git
	fi
}



get_boolector
build_boolector
