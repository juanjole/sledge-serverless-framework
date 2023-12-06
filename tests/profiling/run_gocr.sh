#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r GOCR_WASM="gocr.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=10
declare -r NUMBER_SAMPLES=200
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
declare -r NWORKERS=1

# Tenant configs:
declare -ar TENANT_IDS=("gocr_mono" "gocr_roboto" "gocr")
declare -ar TENANT_MODES=("absolute" "absolute" "absolute")
declare -ar INIT_PORTS=(10000 20000 30000)
declare -ar ROUTES=("gocr-10_72dpi_60195 gocr-10_108dpi_125295 gocr-10_144dpi_200895 gocr-20_72dpi_120015 gocr-20_108dpi_255315 gocr-20_144dpi_414015 gocr-30_72dpi_166395 gocr-30_108dpi_354975 gocr-30_144dpi_576735 \
                     gocr-any10_72dpi_NaN gocr-any10_108dpi_NaN gocr-any10_144dpi_NaN gocr-any20_72dpi_NaN gocr-any20_108dpi_NaN gocr-any20_144dpi_NaN gocr-any30_72dpi_NaN gocr-any30_108dpi_NaN gocr-any30_144dpi_NaN"
                    "gocr-10_72dpi_49484 gocr-10_108dpi_94335 gocr-10_144dpi_159045 gocr-20_72dpi_94094 gocr-20_108dpi_190455 gocr-20_144dpi_320415 gocr-30_72dpi_155115 gocr-30_108dpi_314175 gocr-30_144dpi_539355 \
                     gocr-any10_72dpi_NaN gocr-any10_108dpi_NaN gocr-any10_144dpi_NaN gocr-any20_72dpi_NaN gocr-any20_108dpi_NaN gocr-any20_144dpi_NaN gocr-any30_72dpi_NaN gocr-any30_108dpi_NaN gocr-any30_144dpi_NaN"
                    "gocr-handwritten_238321 gocr-text_4335057")
declare -ar MTDS_REPL_PERIODS_us=(0 0 0)
declare -ar MTDS_MAX_BUDGETS_us=(0 0 0)

# Per route configs:
declare -ar WASM_PATHS=("$GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM \
                         $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM"
                        "$GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM \
                         $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM $GOCR_WASM"
                        "$GOCR_WASM $GOCR_WASM")
declare -ar RESP_CONTENT_TYPES=("text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain"
                                "text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain"
                                "text/plain text/plain")
declare -ar EXPECTED_EXEC_TIMES_us=("5000 5000 5000 5000 5000 5000 5000 5000 5000 \
                                     5000 5000 5000 5000 5000 5000 5000 5000 5000"
                                    "5000 5000 5000 5000 5000 5000 5000 5000 5000 \
                                     5000 5000 5000 5000 5000 5000 5000 5000 5000"
                                    "5000 5000")
declare -ar DEADLINES_us=("25000 25000 25000 25000 25000 25000 25000 25000 25000 \
                           25000 25000 25000 25000 25000 25000 25000 25000 25000"
                          "25000 25000 25000 25000 25000 25000 25000 25000 25000 \
                           25000 25000 25000 25000 25000 25000 25000 25000 25000"
                          "25000 25000")

declare -ar ARG_OPTS_HEY=("-D -D -D -D -D -D -D -D -D \
                           -D -D -D -D -D -D -D -D -D"
                          "-D -D -D -D -D -D -D -D -D \
                           -D -D -D -D -D -D -D -D -D"
                          "-D -D")
declare -ar ARG_OPTS_LT=("-b -b -b -b -b -b -b -b -b \
                          -B -B -B -B -B -B -B -B -B "
                         "-b -b -b -b -b -b -b -b -b \
                          -B -B -B -B -B -B -B -B -B"
                         "-b -b")
declare -ar ARGS=("images/gocr/mono_10_72dpi.pnm images/gocr/mono_10_108dpi.pnm images/gocr/mono_10_144dpi.pnm images/gocr/mono_20_72dpi.pnm images/gocr/mono_20_108dpi.pnm images/gocr/mono_20_144dpi.pnm images/gocr/mono_30_72dpi.pnm images/gocr/mono_30_108dpi.pnm images/gocr/mono_30_144dpi.pnm \
                   images/gocr/mono/10/72dpi/pnm images/gocr/mono/10/108dpi/pnm images/gocr/mono/10/144dpi/pnm images/gocr/mono/20/72dpi/pnm images/gocr/mono/20/108dpi/pnm images/gocr/mono/20/144dpi/pnm images/gocr/mono/30/72dpi/pnm images/gocr/mono/30/108dpi/pnm images/gocr/mono/30/144dpi/pnm"
                  "images/gocr/roboto_10_72dpi.pnm images/gocr/roboto_10_108dpi.pnm images/gocr/roboto_10_144dpi.pnm images/gocr/roboto_20_72dpi.pnm images/gocr/roboto_20_108dpi.pnm images/gocr/roboto_20_144dpi.pnm images/gocr/roboto_30_72dpi.pnm images/gocr/roboto_30_108dpi.pnm images/gocr/roboto_30_144dpi.pnm \
                  images/gocr/roboto/10/72dpi/pnm images/gocr/roboto/10/108dpi/pnm images/gocr/roboto/10/144dpi/pnm images/gocr/roboto/20/72dpi/pnm images/gocr/roboto/20/108dpi/pnm images/gocr/roboto/20/144dpi/pnm images/gocr/roboto/30/72dpi/pnm images/gocr/roboto/30/108dpi/pnm images/gocr/roboto/30/144dpi/pnm"
                  "../gocr/handwriting/handwrt1.pnm ../gocr/hyde/hyde.pnm")

declare -ar PERCENTAGE_LOADS=(25 50 75 100)
declare -ar ABSOLUTE_LOADS=(1)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"
