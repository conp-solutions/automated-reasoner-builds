#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019
#
# This script retrieves and sets up an group MUS benchmark
#
# This benchmark has been used in the 2011 MUS competition, in the group-MUS track
#
# The files provided in this benchmark can be solved, e.g. via: muser2 -grp $file

# in case something goes wrong, notify!
set -ex

BENCHMARK_CATEGORY="MUS"
SUB_CATEGORY="_group"
BENCHMARK_URL="http://www.cril.univ-artois.fr/SAT11/bench/SAT11-Competition-GMUS-SelectedBenchmarks.tar"

# this function retrieves the benchmark and stores it in an accessible way
get_benchmark () {
	# avoid obtaining the benchmark again, if it is available already
	if [ -d "SAT11" ]
	then
		echo "already spotted benchmark directory 'SAT', abort"
		return 0
	fi

	# get benchmark, untar it, and delete tar ball
	wget "$BENCHMARK_URL"
	tar xf SAT11-Competition-GMUS-SelectedBenchmarks.tar
	rm -rf SAT11-Competition-GMUS-SelectedBenchmarks.tar

	# convert bzip2 into gzip, so that tools can handle the files
	for f in $(find . -name "*.bz2")
	do
		b=$(basename "$f")
		c=$(basename "$f" .bz2)
		d=$(dirname "$f")
		pushd "$d" &> /dev/null
		bunzip2 "$b"
		gzip "$c"
		popd
	done
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
