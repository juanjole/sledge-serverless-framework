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
declare -r NWORKERS=1

# Tenant configs:
declare -ar TENANT_IDS=("fib30" "fib36" "fib40")
declare -ar TENANT_MODES=("absolute" "absolute" "absolute")
declare -ar INIT_PORTS=(10000 20000 30000)
declare -ar ROUTES=("fib-30_1x1_1" "fib-36_1x1_1" "fib-40_1x1_1")
declare -ar MTDS_REPL_PERIODS_us=(0 0 0)
declare -ar MTDS_MAX_BUDGETS_us=(0 0 0)

# Per route configs:
declare -ar WASM_PATHS=("$FIBONACCI_WASM" "$FIBONACCI_WASM" "$FIBONACCI_WASM")
declare -ar RESP_CONTENT_TYPES=("text/plain" "text/plain" "text/plain")
#declare -ar EXPECTED_EXEC_TIMES_us=("5250" "95000" "67")
#declare -ar DEADLINES_us=("26250" "475000" "2500000")
declare -ar EXPECTED_EXEC_TIMES_us=("10000" "200000" "1000000")
declare -ar DEADLINES_us=("50000" "1000000" "5000000")

declare -ar ARG_OPTS_HEY=("-d" "-d" "-d")
declare -ar ARG_OPTS_LT=("-P" "-P" "-P")
declare -ar ARGS=("30" "36" "40")

declare -ar PERCENTAGE_LOADS=(10 20 30 40 50 60 70 80 90 100)
declare -ar ABSOLUTE_LOADS=(1)

export SLEDGE_QUANTUM_US=5000
export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=true
export SLEDGE_SANDBOX_PERF_LOG=$(printf "fib-isolated-perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"
