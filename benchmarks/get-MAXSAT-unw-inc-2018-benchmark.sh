#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script retrieves and sets up a MaxSAT benchmark
#
# This benchmark has been used in the 2014 MaxSAT competition
#
# The files provided in this benchmark can be solved, e.g. via: open-wbo $file

# in case something goes wrong, notify!
set -ex

BENCHMARK_CATEGORY="MAXSAT"
SUB_CATEGORY="_wpms-2014"
BENCHMARK_URL="http://www.maxsat.udl.cat/14/benchmarks/wpms_industrial.tgz"

# this function retrieves the benchmark and stores it in an accessible way
get_benchmark () {
	# avoid obtaining the benchmark again, if it is available already
	if [ -d "wpms_industrial" ]
	then
		echo "already spotted benchmark directory 'wpms_industrial', abort"
		return 0
	fi

	# get benchmark, untar it, and delete tar ball
	wget "$BENCHMARK_URL"
	tar xzf wpms_industrial.tgz
	rm wpms_industrial.tgz

	# gzip all plain files again
	for f in $(find . -name "*.wcnf"); do gzip "$f"; done

	# delete files that are unrelated
	rm -f ./wpms_industrial/hs-timetabling/original_xHSTT_instances.tgz
	rm -f ./wpms_industrial/haplotyping-pedigrees/readme
	rm -f ./wpms_industrial/packup-wpms/apt-cudf-universe0ea62c_l1.cnf

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
