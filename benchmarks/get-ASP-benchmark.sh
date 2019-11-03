#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script retrieves and sets up an ASP benchmark
#
# More information about the benchmark can be found in the following publication:
# @inproceedings{DBLP:conf/lion/HoosKSS13,
#   author = {Hoos, Holger H. and Kaufmann, Benjamin and Schaub, Torsten and Schneider, Marius},
#   title = {Robust Benchmark Set Selection for Boolean Constraint Solvers},
#   booktitle = {{LION}},
#   series = {Lecture Notes in Computer Science},
#   volume = {7997},
#   pages = {138--152},
#   publisher = {Springer},
#   year = {2013}
# }

# in case something goes wrong, notify!
set -ex

BENCHMARK_CATEGORY="ASP"
SUB_CATEGORY=""
BENCHMARK_URL="https://www.cs.uni-potsdam.de/wv/projects/sets/set-asp-gauss.tar.xz"

# this function retrieves the benchmark and stores it in an accessible way
get_benchmark () {
	# avoid obtaining the benchmark again, if it is available already
	if [ -d "set-asp-gauss" ]
	then
		echo "already spotted benchmark directory 'set-asp-gauss', abort"
		return 0
	fi

	# get benchmark, untar it, and delete tar ball
	wget "$BENCHMARK_URL"
	tar xf set-asp-gauss.tar.xz
	rm -rf set-asp-gauss.tar.xz
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
