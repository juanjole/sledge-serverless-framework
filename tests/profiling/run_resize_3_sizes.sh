#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r RESIZE_WASM="resize_image.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=10
declare -r NUMBER_SAMPLES=100
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
#declare -r NWORKERS=$(($(nproc)-2)) # all cores - 2
declare -r NWORKERS=1

# Tenant configs:
declare -ar TENANT_IDS=("resize_small" "resize_medium" "resize_large")
declare -ar TENANT_MODES=("absolute" "absolute" "absolute")
declare -ar INIT_PORTS=(10000 20000 30000)
declare -ar ROUTES=("resize_small" "resize_medium" "resize_large")
declare -ar MTDS_REPL_PERIODS_us=(0 0 0)
declare -ar MTDS_MAX_BUDGETS_us=(0 0 0)

# Per route configs:
declare -ar WASM_PATHS=("$RESIZE_WASM" "$RESIZE_WASM" "$RESIZE_WASM")
declare -ar RESP_CONTENT_TYPES=("image/jpg" "image/jpg" "image/jpg")
declare -ar EXPECTED_EXEC_TIMES_us=("23500" "79000" "111510")
declare -ar DEADLINES_us=("117500" "395000" "557550")

declare -ar ARG_OPTS_HEY=("-D" "-D" "-D")
declare -ar ARG_OPTS_LT=("-P" "-P" "-P")
declare -ar ARGS=("images/resize/shrinking_man_small.jpg" "images/resize/shrinking_man_medium.jpg" "images/resize/shrinking_man_large.jpg")

declare -ar PERCENTAGE_LOADS=(25 50 75 100 125)
declare -ar ABSOLUTE_LOADS=(1 2 3 4 5 6 7 8 9 10 15 20)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"
