#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script retrieves and sets up a SAT benchmark
#
# This benchmark has been used in the 2011 MUS competition, in the group-MUS track
#
# The files provided in this benchmark can be solved, e.g. via: minisat $file

# in case something goes wrong, notify!
set -ex

BENCHMARK_CATEGORY="SAT"
SUB_CATEGORY="_2014app"
BENCHMARK_URL="http://satcompetition.org/2014/files/sc14-app.tar"

# this function retrieves the benchmark and stores it in an accessible way
get_benchmark () {
	# avoid obtaining the benchmark again, if it is available already
	if [ -d "sc14-app" ]
	then
		echo "already spotted benchmark directory 'sc14-app', abort"
		return 0
	fi

	# get benchmark, untar it, and delete tar ball
	wget "$BENCHMARK_URL"
	tar xf sc14-app.tar
	rm sc14-app.tar

	# unlzma all compressed files, and gzip them afterwards
	cd sc14-app
	for f in *.lzma
	do
		b=$(basename "$f" .lzma)
		unlzma "$f"
		gzip "$b"
	done

	# remove redundant files that are present in the tar ball
	rm ._*.lzma sc14-app.tar
	cd ..
}


# make sure we work in the directory this script resides in
SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=$(readlink -e "$SCRIPT_DIR")
cd "$SCRIPT_DIR"

# directory to store the benchmark in
TARGET_DIR="${BENCHMARK_CATEGORY}${SUB_CATEGORY}"

mkdir -p "${BENCHMARK_CATEGORY}${SUB_CATEGORY}"
pushd "${BENCHMARK_CATEGORY}${SUB_CATEGORY}"
get_benchmark
popd

BENCHMARK_FILE_COUNT=$(find "${BENCHMARK_CATEGORY}${SUB_CATEGORY}" -type f | wc -l)
echo "Found $BENCHMARK_FILE_COUNT files in benchmark for ${BENCHMARK_CATEGORY}${SUB_CATEGORY}"
