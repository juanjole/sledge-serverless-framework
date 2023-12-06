#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r CIFAR10_WASM="cifar10.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=30
declare -r NUMBER_SAMPLES=200
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
declare -r NWORKERS=5

# Tenant configs:
declare -ar TENANT_IDS=("cifar10_bmp")
declare -ar TENANT_MODES=("absolute")
declare -ar INIT_PORTS=(10000)
declare -ar ROUTES=("cifar10-cat1_32x32_3126 cifar10-ship2_32x32_3126 cifar10-airplane4_32x32_3126 cifar10-frog5_32x32_3126 cifar10-automobile7_32x32_3126 \
                     cifar10-bird26_32x32_3126 cifar10-truck12_32x32_3126 cifar10-dog13_32x32_3126 cifar10-horse14_32x32_3126 cifar10-deer23_32x32_3126 \
                     cifar10-cat_32x32_3126 cifar10-ship_32x32_3126 cifar10-airplane_32x32_3126 cifar10-frog_32x32_3126 cifar10-automobile_32x32_3126 \
                     cifar10-bird_32x32_3126 cifar10-truck_32x32_3126 cifar10-dog_32x32_3126 cifar10-horse_32x32_3126 cifar10-deer_32x32_3126 \
                     cifar10-any_32x32_3126 \
                    ")
declare -ar MTDS_REPL_PERIODS_us=(0)
declare -ar MTDS_MAX_BUDGETS_us=(0)

# Per route configs:
declare -ar WASM_PATHS=("$CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM \
                         $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM $CIFAR10_WASM \
                         $CIFAR10_WASM \
                        ")
declare -ar RESP_CONTENT_TYPES=("text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain \
                                ")
declare -ar EXPECTED_EXEC_TIMES_us=("5500 5500 5500 5500 5500 5500 5500 5500 5500 5500 \
                                     5500 5500 5500 5500 5500 5500 5500 5500 5500 5500 \
                                     5500 \
                                    ")
declare -ar DEADLINES_us=("27500 27500 27500 27500 27500 27500 27500 27500 27500 27500 \
                           27500 27500 27500 27500 27500 27500 27500 27500 27500 27500 \
                           27500 \
                          ")

# For image data:
declare -ar ARG_OPTS_HEY=("-D -D -D -D -D -D -D -D -D -D \
                           -D -D -D -D -D -D -D -D -D -D \
                           -D \
                          ")
declare -ar ARG_OPTS_LT=("-b -b -b -b -b -b -b -b -b -b \
                          -B -B -B -B -B -B -B -B -B -B \
                          -B \
                         ")
declare -ar ARGS=("images/cifar10/32x32_test/bmp/cat/1_cat.bmp images/cifar10/32x32_test/bmp/ship/2_ship.bmp images/cifar10/32x32_test/bmp/airplane/4_airplane.bmp images/cifar10/32x32_test/bmp/frog/5_frog.bmp images/cifar10/32x32_test/bmp/automobile/7_automobile.bmp \
                   images/cifar10/32x32_test/bmp/bird/26_bird.bmp images/cifar10/32x32_test/bmp/truck/12_truck.bmp images/cifar10/32x32_test/bmp/dog/13_dog.bmp images/cifar10/32x32_test/bmp/horse/14_horse.bmp images/cifar10/32x32_test/bmp/deer/23_deer.bmp \
                   images/cifar10/32x32_test/bmp/cat images/cifar10/32x32_test/bmp/ship images/cifar10/32x32_test/bmp/airplane images/cifar10/32x32_test/bmp/frog images/cifar10/32x32_test/bmp/automobile \
                   images/cifar10/32x32_test/bmp/bird images/cifar10/32x32_test/bmp/truck images/cifar10/32x32_test/bmp/dog images/cifar10/32x32_test/bmp/horse images/cifar10/32x32_test/bmp/deer \
                   images/cifar10/32x32_test/bmp/any \
                  ")

declare -ar PERCENTAGE_LOADS=(10 20 30 40 50 60 70 80 90 100)
declare -ar ABSOLUTE_LOADS=(1 2 3 4 5 6 7 8 9 10)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "cifar10-perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"
