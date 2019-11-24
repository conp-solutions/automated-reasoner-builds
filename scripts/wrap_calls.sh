#!/usr/bin/env bash
#
# Copyright Norbert Manthey, 2019

# Produce a list of commands to run
#
# Example usage, to run commands of a file and measure the time
#    ./wrap_calls.sh \
#        -w "/usr/bin/time -v" \
#        -i solver-calls.txt

set -e

# the final binary should be moved here
SCRIPT="$0"
SCRIPT_DIR=$(dirname "$SCRIPT")

# print the usage information for this script
usage ()
{
cat << EOF
This script generates the commands that have to be executed to benchmark a
solver, where each solver call is given as a line of a file already.

usage: $SCRIPT [option]

   options:
    -i input ..... file with calls to wrap, one on each line
    -w wrapper ... wrapper that is placed before solver

EOF
}

# arguments to be used in the script
INPUT=""           # read benchmarks from this file, instead of from directory
WRAPPER=""

# evaluate options
while getopts "e:hi:w:" OPTION; do
    case $OPTION in
    e) ENVIRONMENT="$OPTARG " ;;
    h) usage; exit 0;;
    i) INPUT="$OPTARG" ;;
    w) WRAPPER="$OPTARG" ;;
    *)
        echo "Unknown option provided, abort"
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))

# generate benchmark list
cat "$INPUT" | while read BENCHMARK
do
	unset RUN_CMD
	declare -a RUN_CMD
	[ -z "$WRAPPER" ] || RUN_CMD+=("$WRAPPER")
	RUN_CMD+=(${TOOL_COMMAND[@]})

	# make sure we place the benchmark at the right location
	[ ! -r "$BENCHMARK" ] || BENCHMARK="$(readlink -e "$benchmark")"
	RUN_CMD+=("$BENCHMARK")

	# print the full line to be executed
	echo "${ENVIRONMENT}${RUN_CMD[@]}"
done
