#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r EKF_WASM="gps_ekf.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=15
declare -r NUMBER_SAMPLES=200
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
declare -r NWORKERS=5

# Tenant configs:
declare -ar TENANT_IDS=("ekf")
declare -ar TENANT_MODES=("absolute")
declare -ar INIT_PORTS=(10000)
declare -ar ROUTES=("ekf-any_1x1_5088 ekf-0_1x1_5088 ekf-1_1x1_5088 ekf-2_1x1_5088 ekf-3_1x1_5088 ekf-4_1x1_5088 \
                     ekf-5_1x1_5088 ekf-6_1x1_5088 ekf-7_1x1_5088 ekf-8_1x1_5088 ekf-9_1x1_5088 ekf-10_1x1_5088")
declare -ar MTDS_REPL_PERIODS_us=(0)
declare -ar MTDS_MAX_BUDGETS_us=(0)

# Per route configs:
declare -ar WASM_PATHS=("$EKF_WASM $EKF_WASM $EKF_WASM $EKF_WASM $EKF_WASM $EKF_WASM \
                         $EKF_WASM $EKF_WASM $EKF_WASM $EKF_WASM $EKF_WASM $EKF_WASM")
declare -ar RESP_CONTENT_TYPES=("application/octet-stream application/octet-stream application/octet-stream application/octet-stream application/octet-stream application/octet-stream \
                                 application/octet-stream application/octet-stream application/octet-stream application/octet-stream application/octet-stream application/octet-stream")
declare -ar EXPECTED_EXEC_TIMES_us=("7 7 7 7 7 7 7 7 7 7 7 7")
declare -ar DEADLINES_us=("35 35 35 35 35 35 35 35 35 35 35 35")

declare -ar ARG_OPTS_HEY=("-D -D -D -D -D -D -D -D -D -D -D -D")
declare -ar ARG_OPTS_LT=("-B -b -b -b -b -b -b -b -b -b -b -b")
declare -ar ARGS=("ekf ekf/iter00.dat ekf/iter01.dat ekf/iter02.dat ekf/iter03.dat ekf/iter04.dat ekf/iter05.dat ekf/iter06.dat ekf/iter07.dat ekf/iter08.dat ekf/iter09.dat ekf/iter10.dat")

declare -ar PERCENTAGE_LOADS=(25 50 75 100)
declare -ar ABSOLUTE_LOADS=(1 2 3 4 5 6 7 8 9 10)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "ekf-perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"
