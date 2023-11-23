#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r FIBONACCI_WASM="fibonacci.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=10
declare -r NUMBER_SAMPLES=200
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
declare -r NWORKERS=5

# Tenant configs:
declare -ar TENANT_IDS=("fib30" "fib36")
declare -ar TENANT_MODES=("absolute" "absolute")
declare -ar INIT_PORTS=(10000 20000)
declare -ar ROUTES=("fib-30_1x1_1" "fib-36_1x1_1")
declare -ar MTDS_REPL_PERIODS_us=(0 0)
declare -ar MTDS_MAX_BUDGETS_us=(0 0)

# Per route configs:
declare -ar WASM_PATHS=("$FIBONACCI_WASM" "$FIBONACCI_WASM")
declare -ar RESP_CONTENT_TYPES=("text/plain" "text/plain")
declare -ar EXPECTED_EXEC_TIMES_us=("5250" "95000")
declare -ar DEADLINES_us=("26250" "475000")

declare -ar ARG_OPTS_HEY=("-d" "-d")
declare -ar ARG_OPTS_LT=("-P" "-P")
declare -ar ARGS=("30" "36")

declare -ar PERCENTAGE_LOADS=(10 20 30 40 50 60 70 80 90 100)
declare -ar ABSOLUTE_LOADS=(1 2 3 4 5 6 7 8 9 10 15 25 50 100)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "fib-perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"
