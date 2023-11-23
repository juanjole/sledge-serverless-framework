#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r RESIZE_WASM="resize_image.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=15
declare -r NUMBER_SAMPLES=200
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
declare -r NWORKERS=1

# Tenant configs:
declare -ar TENANT_IDS=("resize_bmp" "resize_jpg" "resize_png")
declare -ar TENANT_MODES=("absolute" "absolute" "absolute")
declare -ar INIT_PORTS=(10000 20000 30000)

declare -ar ROUTES=("resize-any_64x64_NaN resize-random_64x64_12342 resize-red_64x64_12342 resize-green_64x64_12342 resize-blue_64x64_12342 \
                     resize-any_64x128_NaN resize-random_64x128_24630 resize-red_64x128_24630 resize-green_64x128_24630 resize-blue_64x128_24630 \
                     resize-any_128x128_NaN resize-random_128x128_49206 resize-red_128x128_49206 resize-green_128x128_49206 resize-blue_128x128_49206 \
                     resize-any_128x256_NaN resize-random_128x256_98358 resize-red_128x256_98358 resize-green_128x256_98358 resize-blue_128x256_98358 \
                     resize-any_256x256_NaN resize-random_256x256_196662 resize-red_256x256_196662 resize-green_256x256_196662 resize-blue_256x256_196662 \
                     resize-any_256x512_NaN resize-random_256x512_393270 resize-red_256x512_393270 resize-green_256x512_393270 resize-blue_256x512_393270 \
                     resize-any_512x512_NaN resize-random_512x512_786486 resize-red_512x512_786486 resize-green_512x512_786486 resize-blue_512x512_786486 \
                     resize-any_512x1024_NaN resize-random_512x1024_1572918 resize-red_512x1024_1572918 resize-green_512x1024_1572918 resize-blue_512x1024_1572918 \
                     resize-any_1024x1024_NaN resize-random_1024x1024_3145782 resize-red_1024x1024_3145782 resize-green_1024x1024_3145782 resize-blue_1024x1024_3145782"

                    "resize-any_64x64_NaN resize-random_64x64_3073 resize-red_64x64_693 resize-green_64x64_693 resize-blue_64x64_693 \
                     resize-any_64x128_NaN resize-random_64x128_5529 resize-red_64x128_757 resize-green_64x128_757 resize-blue_64x128_757 \
                     resize-any_128x128_NaN resize-random_128x128_10470 resize-red_128x128_885 resize-green_128x128_885 resize-blue_128x128_885 \
                     resize-any_128x256_NaN resize-random_128x256_20320 resize-red_128x256_1141 resize-green_128x256_1141 resize-blue_128x256_1141 \
                     resize-any_256x256_NaN resize-random_256x256_39957 resize-red_256x256_1653 resize-green_256x256_1653 resize-blue_256x256_1653 \
                     resize-any_256x512_NaN resize-random_256x512_79237 resize-red_256x512_2677 resize-green_256x512_2677 resize-blue_256x512_2677 \
                     resize-any_512x512_NaN resize-random_512x512_157799 resize-red_512x512_4725 resize-green_512x512_4725 resize-blue_512x512_4725 \
                     resize-any_512x1024_NaN resize-random_512x1024_315263 resize-red_512x1024_8821 resize-green_512x1024_8821 resize-blue_512x1024_8821 \
                     resize-any_1024x1024_NaN resize-random_1024x1024_629748 resize-red_1024x1024_17013 resize-green_1024x1024_17013 resize-blue_1024x1024_17013"

                    "resize-any_64x64_NaN resize-random_64x64_12451 resize-red_64x64_172 resize-green_64x64_172 resize-blue_64x64_172 \
                     resize-any_64x128_NaN resize-random_64x128_24768 resize-red_64x128_240 resize-green_64x128_241 resize-blue_64x128_241 \
                     resize-any_128x128_NaN resize-random_128x128_49454 resize-red_128x128_376 resize-green_128x128_377 resize-blue_128x128_377 \
                     resize-any_128x256_NaN resize-random_128x256_98693 resize-red_128x256_440 resize-green_128x256_440 resize-blue_128x256_441 \
                     resize-any_256x256_NaN resize-random_256x256_197299 resize-red_256x256_776 resize-green_256x256_776 resize-blue_256x256_777 \
                     resize-any_256x512_NaN resize-random_256x512_394255 resize-red_256x512_1000 resize-green_256x512_1000 resize-blue_256x512_1001 \
                     resize-any_512x512_NaN resize-random_512x512_788423 resize-red_512x512_1896 resize-green_512x512_1896 resize-blue_512x512_1897 \
                     resize-any_512x1024_NaN resize-random_512x1024_1576247 resize-red_512x1024_2728 resize-green_512x1024_2728 resize-blue_512x1024_2729 \
                     resize-any_1024x1024_NaN resize-random_1024x1024_3152407 resize-red_1024x1024_5352 resize-green_1024x1024_5352 resize-blue_1024x1024_5353")
declare -ar MTDS_REPL_PERIODS_us=(0 0 0)
declare -ar MTDS_MAX_BUDGETS_us=(0 0 0)

# Per route configs:
declare -ar WASM_PATHS=("$RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM"

                        "$RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM"

                        "$RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM \
                         $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM $RESIZE_WASM")
declare -ar RESP_CONTENT_TYPES=("image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp \
                                 image/bmp image/bmp image/bmp image/bmp image/bmp"

                                "image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg \
                                 image/jpg image/jpg image/jpg image/jpg image/jpg"

                                "image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png \
                                 image/png image/png image/png image/png image/png")
declare -ar EXPECTED_EXEC_TIMES_us=("400 400 250 250 250 \
                                     750 750 400 400 400 \
                                     1300 1400 800 800 800 \
                                     2250 2800 1500 1500 1500 \
                                     5000 5300 3000 3000 3000 \
                                     9000 11000 6000 6000 6000 \
                                     18000 22000 12000 12000 12000 \
                                     31000 43000 24000 24000 24000 \
                                     72000 85000 47000 47000 47000"

                                   "400 400 250 250 250 \
                                    750 750 400 400 400 \
                                    1300 1400 800 800 800 \
                                    2250 2800 1500 1500 1500 \
                                    5000 5300 3000 3000 3000 \
                                    9000 11000 6000 6000 6000 \
                                    18000 22000 12000 12000 12000 \
                                    31000 43000 24000 24000 24000 \
                                    72000 85000 47000 47000 47000"

                                   "400 400 250 250 250 \
                                    750 750 400 400 400 \
                                    1300 1400 800 800 800 \
                                    2250 2800 1500 1500 1500 \
                                    5000 5300 3000 3000 3000 \
                                    9000 11000 6000 6000 6000 \
                                    18000 22000 12000 12000 12000 \
                                    31000 43000 24000 24000 24000 \
                                    72000 85000 47000 47000 47000")
declare -ar DEADLINES_us=("2000 2000 1250 1250 1250 \
                           3750 3750 2000 2000 2000 \
                           6500 7000 4000 4000 4000 \
                           11250 14000 7500 7500 7500 \
                           25000 26500 15000 15000 15000 \
                           45000 55000 30000 30000 30000 \
                           90000 110000 60000 60000 60000 \
                           155000 215000 120000 120000 120000 \
                           360000 425000 235000 235000 235000"

                          "2000 2000 1250 1250 1250 \
                           3750 3750 2000 2000 2000 \
                           6500 7000 4000 4000 4000 \
                           11250 14000 7500 7500 7500 \
                           25000 26500 15000 15000 15000 \
                           45000 55000 30000 30000 30000 \
                           90000 110000 60000 60000 60000 \
                           155000 215000 120000 120000 120000 \
                           360000 425000 235000 235000 235000"

                          "2000 2000 1250 1250 1250 \
                           3750 3750 2000 2000 2000 \
                           6500 7000 4000 4000 4000 \
                           11250 14000 7500 7500 7500 \
                           25000 26500 15000 15000 15000 \
                           45000 55000 30000 30000 30000 \
                           90000 110000 60000 60000 60000 \
                           155000 215000 120000 120000 120000 \
                           360000 425000 235000 235000 235000")

declare -ar ARG_OPTS_HEY=("-D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D"

                          "-D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D"

                          "-D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D \
                           -D -D -D -D -D")
declare -ar ARG_OPTS_LT=("-B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b"

                         "-B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b"

                         "-B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b \
                          -B -b -b -b -b")
declare -ar ARGS=("images/picsum/64x64/bmp images/resize/dataset/bmp/random_64x64.bmp images/resize/dataset/bmp/red_64x64.bmp images/resize/dataset/bmp/green_64x64.bmp images/resize/dataset/bmp/blue_64x64.bmp \
                   images/picsum/64x128/bmp images/resize/dataset/bmp/random_64x128.bmp images/resize/dataset/bmp/red_64x128.bmp images/resize/dataset/bmp/green_64x128.bmp images/resize/dataset/bmp/blue_64x128.bmp \
                   images/picsum/128x128/bmp images/resize/dataset/bmp/random_128x128.bmp images/resize/dataset/bmp/red_128x128.bmp images/resize/dataset/bmp/green_128x128.bmp images/resize/dataset/bmp/blue_128x128.bmp \
                   images/picsum/128x256/bmp images/resize/dataset/bmp/random_128x256.bmp images/resize/dataset/bmp/red_128x256.bmp images/resize/dataset/bmp/green_128x256.bmp images/resize/dataset/bmp/blue_128x256.bmp \
                   images/picsum/256x256/bmp images/resize/dataset/bmp/random_256x256.bmp images/resize/dataset/bmp/red_256x256.bmp images/resize/dataset/bmp/green_256x256.bmp images/resize/dataset/bmp/blue_256x256.bmp \
                   images/picsum/256x512/bmp images/resize/dataset/bmp/random_256x512.bmp images/resize/dataset/bmp/red_256x512.bmp images/resize/dataset/bmp/green_256x512.bmp images/resize/dataset/bmp/blue_256x512.bmp \
                   images/picsum/512x512/bmp images/resize/dataset/bmp/random_512x512.bmp images/resize/dataset/bmp/red_512x512.bmp images/resize/dataset/bmp/green_512x512.bmp images/resize/dataset/bmp/blue_512x512.bmp \
                   images/picsum/512x1024/bmp images/resize/dataset/bmp/random_512x1024.bmp images/resize/dataset/bmp/red_512x1024.bmp images/resize/dataset/bmp/green_512x1024.bmp images/resize/dataset/bmp/blue_512x1024.bmp \
                   images/picsum/1024x1024/bmp images/resize/dataset/bmp/random_1024x1024.bmp images/resize/dataset/bmp/red_1024x1024.bmp images/resize/dataset/bmp/green_1024x1024.bmp images/resize/dataset/bmp/blue_1024x1024.bmp"

                  "images/picsum/64x64/jpg images/resize/dataset/jpg/random_64x64.jpg images/resize/dataset/jpg/red_64x64.jpg images/resize/dataset/jpg/green_64x64.jpg images/resize/dataset/jpg/blue_64x64.jpg \
                   images/picsum/64x128/jpg images/resize/dataset/jpg/random_64x128.jpg images/resize/dataset/jpg/red_64x128.jpg images/resize/dataset/jpg/green_64x128.jpg images/resize/dataset/jpg/blue_64x128.jpg \
                   images/picsum/128x128/jpg images/resize/dataset/jpg/random_128x128.jpg images/resize/dataset/jpg/red_128x128.jpg images/resize/dataset/jpg/green_128x128.jpg images/resize/dataset/jpg/blue_128x128.jpg \
                   images/picsum/128x256/jpg images/resize/dataset/jpg/random_128x256.jpg images/resize/dataset/jpg/red_128x256.jpg images/resize/dataset/jpg/green_128x256.jpg images/resize/dataset/jpg/blue_128x256.jpg \
                   images/picsum/256x256/jpg images/resize/dataset/jpg/random_256x256.jpg images/resize/dataset/jpg/red_256x256.jpg images/resize/dataset/jpg/green_256x256.jpg images/resize/dataset/jpg/blue_256x256.jpg \
                   images/picsum/256x512/jpg images/resize/dataset/jpg/random_256x512.jpg images/resize/dataset/jpg/red_256x512.jpg images/resize/dataset/jpg/green_256x512.jpg images/resize/dataset/jpg/blue_256x512.jpg \
                   images/picsum/512x512/jpg images/resize/dataset/jpg/random_512x512.jpg images/resize/dataset/jpg/red_512x512.jpg images/resize/dataset/jpg/green_512x512.jpg images/resize/dataset/jpg/blue_512x512.jpg \
                   images/picsum/512x1024/jpg images/resize/dataset/jpg/random_512x1024.jpg images/resize/dataset/jpg/red_512x1024.jpg images/resize/dataset/jpg/green_512x1024.jpg images/resize/dataset/jpg/blue_512x1024.jpg \
                   images/picsum/1024x1024/jpg images/resize/dataset/jpg/random_1024x1024.jpg images/resize/dataset/jpg/red_1024x1024.jpg images/resize/dataset/jpg/green_1024x1024.jpg images/resize/dataset/jpg/blue_1024x1024.jpg"

                  "images/picsum/64x64/png images/resize/dataset/png/random_64x64.png images/resize/dataset/png/red_64x64.png images/resize/dataset/png/green_64x64.png images/resize/dataset/png/blue_64x64.png \
                   images/picsum/64x128/png images/resize/dataset/png/random_64x128.png images/resize/dataset/png/red_64x128.png images/resize/dataset/png/green_64x128.png images/resize/dataset/png/blue_64x128.png \
                   images/picsum/128x128/png images/resize/dataset/png/random_128x128.png images/resize/dataset/png/red_128x128.png images/resize/dataset/png/green_128x128.png images/resize/dataset/png/blue_128x128.png \
                   images/picsum/128x256/png images/resize/dataset/png/random_128x256.png images/resize/dataset/png/red_128x256.png images/resize/dataset/png/green_128x256.png images/resize/dataset/png/blue_128x256.png \
                   images/picsum/256x256/png images/resize/dataset/png/random_256x256.png images/resize/dataset/png/red_256x256.png images/resize/dataset/png/green_256x256.png images/resize/dataset/png/blue_256x256.png \
                   images/picsum/256x512/png images/resize/dataset/png/random_256x512.png images/resize/dataset/png/red_256x512.png images/resize/dataset/png/green_256x512.png images/resize/dataset/png/blue_256x512.png \
                   images/picsum/512x512/png images/resize/dataset/png/random_512x512.png images/resize/dataset/png/red_512x512.png images/resize/dataset/png/green_512x512.png images/resize/dataset/png/blue_512x512.png \
                   images/picsum/512x1024/png images/resize/dataset/png/random_512x1024.png images/resize/dataset/png/red_512x1024.png images/resize/dataset/png/green_512x1024.png images/resize/dataset/png/blue_512x1024.png \
                   images/picsum/1024x1024/png images/resize/dataset/png/random_1024x1024.png images/resize/dataset/png/red_1024x1024.png images/resize/dataset/png/green_1024x1024.png images/resize/dataset/png/blue_1024x1024.png")

declare -ar PERCENTAGE_LOADS=(25 50 75 100 125)
declare -ar ABSOLUTE_LOADS=(1 2 3 4 5 6 7 8 9)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "resize-new-perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"