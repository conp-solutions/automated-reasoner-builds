#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script retrieves and sets up a Software Model Checking benchmark,
#
# Taken from LLBMC: BMC of C and C++ Programs using a Compiler IR, VSTTE 2012
#
# The files in the benchmark require furter tweaking to be solved. The scripts
# to run CBMC only work with the version that was available at the time.

# in case something goes wrong, notify!
set -ex

BENCHMARK_CATEGORY="SWMC"
SUB_CATEGORY="_llbmc_1.1"
BENCHMARK_URL="http://llbmc.org/files/downloads/llbmc-bench-1.1.tgz"

# this function retrieves the benchmark and stores it in an accessible way
get_benchmark () {
	# avoid obtaining the benchmark again, if it is available already
	if [ -d "llbmc-bench" ]
	then
		echo "already spotted benchmark directory 'llbmc-bench', abort"
		return 0
	fi

	# get benchmark, untar it, and delete tar ball
	wget "$BENCHMARK_URL"
	tar xfz llbmc-bench-1.1.tgz
	rm llbmc-bench-1.1.tgz
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

BENCHMARK_FILE_COUNT=$(find "${BENCHMARK_CATEGORY}${SUB_CATEGORY}" -type f -name "*.c" | wc -l)
echo "Found $BENCHMARK_FILE_COUNT files in benchmark for ${BENCHMARK_CATEGORY}${SUB_CATEGORY}"
