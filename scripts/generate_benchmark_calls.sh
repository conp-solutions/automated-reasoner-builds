#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019

# Produce a list of commands to run for a given
#
# Example usage, to run minisat on some benchmark and measure the time
#    ./generate_benchmark_calls.sh -b \
#        -w "/usr/bin/time -v" \
#        -s cnf \
#        SATbenchmark \
#        minisat -no-pre

set -e

# the final binary should be moved here
SCRIPT="$0"
SCRIPT_DIR=$(dirname "$SCRIPT")

# print the usage information for this script
usage ()
{
cat << EOF
This script generates the commands that have to be executed to benchmark a
solver for a given directory. A command line for each benchmark is printed.

usage: $SCRIPT [option] directory tool-cmd
   directory ... directory that contains all benchmark files
   tool-cmd .... tool command with parameters, by default expects benchmark
                 as the last parameter in the call

   options:
    -f filter .... command that reads from stdin and writes to stdout to filter
                   or sort the spotted benchmarks
    -s suffix .... suffix of the benchmark files to be considered
    -w wrapper ... wrapper that is placed before solver

EOF
}

# arguments to be used in the script
BENCHMARK_FIRST=0  # have the benchmark file right after the solver binary
declare -a FILTER  # filters to be used to sort the benchmarks, e.g. sort -V
SUFFIX=""
WRAPPER=""

# evaluate options
while getopts "be:f:hs:w:" OPTION; do
    case $OPTION in
    b) BENCHMARK_FIRST=1 ;;
    e) ENVIRONMENT="$OPTARG " ;;
    f) FILTER+=("$OPTARG") ;;
    h) usage; exit 0;;
    s) SUFFIX="$OPTARG" ;;
    w) WRAPPER="$OPTARG" ;;
    *)
        echo "Unknown option provided, abort"
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))

BENCHMARK_DIRECTORY="$1"
shift
TOOL_COMMAND=($@)  # tool to be called, last parameter has to be the benchmark

# extend the suffix
[ -z "$SUFFIX" ] || SUFFIX=" -name *.$SUFFIX"

if [ ! -d "$BENCHMARK_DIRECTORY" ]
then
    echo "specified directory $BENCHMARK_DIRECTORY cannot be found, abort"	
    exit 1
fi

readlink -e ${TOOL_COMMAND[0]} &> /dev/null && TOOL_COMMAND[0]=$(readlink -e ${TOOL_COMMAND[0]})
echo "generate benchmark for ${TOOL_COMMAND[0]}" 1>&2

# filter all spotted benchmarks with given filters
ALL_BENCHMARKS="$(find "$BENCHMARK_DIRECTORY" -type f $SUFFIX)"
for filter in "${FILTER[@]}"
do
	echo "Filter: $filter"  1>&2
	ALL_BENCHMARKS="$(echo "$ALL_BENCHMARKS" | ${filter})"
done

# generate benchmark list
for benchmark in $ALL_BENCHMARKS
do
	unset RUN_CMD
	declare -a RUN_CMD
	[ -z "$WRAPPER" ] || RUN_CMD+=("$WRAPPER")
	RUN_CMD+=(${TOOL_COMMAND[@]})

	# make sure we place the benchmark at the right location
	BENCHMARK="$(readlink -e "$benchmark")"
	if [ "$BENCHMARK_FIRST" -eq 0 ]
	then
		RUN_CMD+=("$BENCHMARK")
	else
		RUN_CMD=("${RUN_CMD[@]:1:1}" "$BENCHMARK" "${RUN_CMD[@]:2}")
	fi

	# print the full line to be executed
	echo "${ENVIRONMENT}${RUN_CMD[@]}"
done
