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

BENCHMARK_CATEGORY="AIG"
SUB_CATEGORY="_hwmcc17-deep"
BENCHMARK_URL="http://fmv.jku.at/hwmcc17/hwmcc17-single-benchmarks.tar.xz"

# this function retrieves the benchmark and stores it in an accessible way
get_benchmark () {
	# avoid obtaining the benchmark again, if it is available already
	if [ -d "selected_files" ]
	then
		echo "already spotted benchmark directory 'selected_files', abort"
		return 0
	fi

	# get benchmark, untar it, and delete tar ball
	wget "$BENCHMARK_URL"
	tar xf hwmcc17-single-benchmarks.tar.xz
	rm hwmcc17-single-benchmarks.tar.xz

	# get files that have been part in hwmcc 2017
	wget http://fmv.jku.at/hwmcc17/deep.csv
	awk -F';' '{print $1 ".aig"}' deep.csv > deep-benchmark.txt

	# create directory to put these files into, and move used files
	mkdir -p selected_files
	mv $(cat deep-benchmark.txt | xargs) selected_files/

	# remove any remainint benchmark file
	rm -rf *.aig
	rm deep-benchmark.txt deep.csv

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
