#!/bin/bash

# shellcheck disable=SC1091,SC2034,SC2155

source ../bash_libraries/profiling.sh || exit 1

# To reduce post processing time, provide local-only meaningful metrics:
# Comment the following line in order to use ALL the metrics!
declare -a SANDBOX_METRICS=(total running_sys running_user)

declare -r LPD_WASM="license_plate_detection.wasm.so"

# The global configs for the scripts
declare -r CLIENT_TERMINATE_SERVER=true
declare -r DURATION_sec=30
declare -r NUMBER_SAMPLES=200
declare -r SAMPLE_MODE=true
declare -r ESTIMATIONS_PERCENTILE=60
declare -r NWORKERS=1

declare -ar TENANT_IDS=("lpd_bmp" "lpd_jpg" "lpd_png")
declare -ar TENANT_MODES=("absolute" "absolute" "absolute")
declare -ar INIT_PORTS=(20000 30000 40000)
declare -ar ROUTES=(
#                    "lpd-0_3_500x268_181641 lpd-1_0_400x248_541584 lpd-2_4_400x400_913899 lpd-3_1_400x225_499510 \
#                     lpd-4_2_590x350_225326 lpd-71_0_400x225_525421 lpd-87_1_400x290_650645 lpd-106_0_400x247_533800 \
#                     lpd-143_0_400x267_584820 lpd-146_0_400x300_704411 lpd-249_0_400x247_554077 lpd-277_0_400x291_649749 \
#                     lpd-295_1_400x256_581663 lpd-316_1_600x450_377693 lpd-330_0_400x300_540758 \
#                     lpd-5_1_400x295_655641 lpd-6_1_500x375_257806 lpd-9_4_442x333_186756 lpd-12_2_400x141_297682 \
#                     lpd-14_2_400x225_468225 lpd-15_2_400x267_557755 lpd-23_3_400x299_661699 lpd-34_NaN_400x332_716719 \
#                     lpd-37_3_400x268_419481 lpd-38_NaN_386x400_754547 lpd-46_NaN_400x353_788418 \
#                     lpd-any_NaN_NaN_NaN"

                    "lpd-0_3_500x268_402054 lpd-1_0_400x248_297654 lpd-2_4_400x400_480054 lpd-3_1_400x225_270054 \
                     lpd-4_2_590x350_620254 lpd-71_0_400x225_270054 lpd-87_1_400x290_348054 lpd-106_0_400x247_296454 \
                     lpd-143_0_400x267_320454 lpd-146_0_400x300_360054 lpd-249_0_400x247_296454 lpd-277_0_400x291_349254 \
                     lpd-295_1_400x256_307254 lpd-316_1_600x450_810054 lpd-330_0_400x300_360054 \
                     lpd-5_1_400x295_354054 lpd-6_1_500x375_562554 lpd-9_4_442x333_442278 lpd-12_2_400x141_169254 \
                     lpd-14_2_400x225_270054 lpd-15_2_400x267_320454 lpd-23_3_400x299_358854 lpd-34_NaN_400x332_398454 \
                     lpd-37_3_400x268_321654 lpd-38_NaN_386x400_464054 lpd-46_NaN_400x353_423654 \
                     lpd-any_NaN_NaN_NaN"

                    "lpd-0_3_500x268_22724 lpd-1_0_400x248_17337 lpd-2_4_400x400_27375 lpd-3_1_400x225_19080 \
                     lpd-4_2_590x350_34472 lpd-71_0_400x225_21393 lpd-87_1_400x290_21974 lpd-106_0_400x247_22480 \
                     lpd-143_0_400x267_21205 lpd-146_0_400x300_26696 lpd-249_0_400x247_23642 lpd-277_0_400x291_29248 \
                     lpd-295_1_400x256_19081 lpd-316_1_600x450_48396 lpd-330_0_400x300_29590 \
                     lpd-5_1_400x295_27558 lpd-6_1_500x375_29171 lpd-9_4_442x333_22389 lpd-12_2_400x141_10591 \
                     lpd-14_2_400x225_13605 lpd-15_2_400x267_17816 lpd-23_3_400x299_20789 lpd-34_NaN_400x332_22480 \
                     lpd-37_3_400x268_17863 lpd-38_NaN_386x400_22922 lpd-46_NaN_400x353_24855 \
                     lpd-any_NaN_NaN_NaN"

                     "lpd-0_3_500x268_170985 lpd-1_0_400x248_143741 lpd-2_4_400x400_261035 lpd-3_1_400x225_142078 \
                     lpd-4_2_590x350_211583 lpd-71_0_400x225_159768 lpd-87_1_400x290_185745 lpd-106_0_400x247_165872 \
                     lpd-143_0_400x267_172193 lpd-146_0_400x300_214438 lpd-249_0_400x247_176783 lpd-277_0_400x291_204343 \
                     lpd-295_1_400x256_163403 lpd-316_1_600x450_358767 lpd-330_0_400x300_222488 \
                     lpd-5_1_400x295_203362 lpd-6_1_500x375_227675 lpd-9_4_442x333_170366 lpd-12_2_400x141_76524 \
                     lpd-14_2_400x225_111744 lpd-15_2_400x267_153118 lpd-23_3_400x299_176574 lpd-34_NaN_400x332_185581 \
                     lpd-37_3_400x268_111068 lpd-38_NaN_386x400_189099 lpd-46_NaN_400x353_202509 \
                     lpd-any_NaN_NaN_NaN")
declare -ar MTDS_REPL_PERIODS_us=(0 0 0)
declare -ar MTDS_MAX_BUDGETS_us=(0 0 0)

declare -ar WASM_PATHS=(
#                        "$LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
#                         $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
#                         $LPD_WASM"
                        "$LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
                         $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
                         $LPD_WASM"
                        "$LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
                         $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
                         $LPD_WASM"
                        "$LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
                         $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM $LPD_WASM \
                         $LPD_WASM")
declare -ar RESP_CONTENT_TYPES=(
#                                "text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
#                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
#                                 text/plain"
                                "text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain"
                                "text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain"
                                "text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain text/plain \
                                 text/plain")
declare -ar EXPECTED_EXEC_TIMES_us=(
#                                    "40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
#                                     40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
#                                     40000"
                                    "40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
                                     40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
                                     40000"
                                    "40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
                                     40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
                                     40000"
                                    "40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
                                     40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 40000 \
                                     40000")
declare -ar DEADLINES_us=(
#                          "200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
#                           200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
#                           200000"
                          "200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
                           200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
                           200000"
                          "200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
                           200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
                           200000"
                          "200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
                           200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 200000 \
                           200000")

declare -ar ARG_OPTS_HEY=(
#                          "-D -D -D -D -D -D -D -D -D -D -D -D -D -D -D \
#                           -D -D -D -D -D -D -D -D -D -D -D \
#                           -D"
                          "-D -D -D -D -D -D -D -D -D -D -D -D -D -D -D \
                           -D -D -D -D -D -D -D -D -D -D -D \
                           -D"
                          "-D -D -D -D -D -D -D -D -D -D -D -D -D -D -D \
                           -D -D -D -D -D -D -D -D -D -D -D \
                           -D"
                          "-D -D -D -D -D -D -D -D -D -D -D -D -D -D -D \
                           -D -D -D -D -D -D -D -D -D -D -D \
                           -D")
declare -ar ARG_OPTS_LT=(
#                         "-b -b -b -b -b -b -b -b -b -b -b -b -b -b -b \
#                          -b -b -b -b -b -b -b -b -b -b -b \
#                          -B"
                         "-b -b -b -b -b -b -b -b -b -b -b -b -b -b -b \
                          -b -b -b -b -b -b -b -b -b -b -b \
                          -B"
                         "-b -b -b -b -b -b -b -b -b -b -b -b -b -b -b \
                          -b -b -b -b -b -b -b -b -b -b -b \
                          -B"
                         "-b -b -b -b -b -b -b -b -b -b -b -b -b -b -b \
                          -b -b -b -b -b -b -b -b -b -b -b \
                          -B")
declare -ar ARGS=(
#                  "images/lpd/orig/Cars0.png images/lpd/orig/Cars1.png images/lpd/orig/Cars2.png images/lpd/orig/Cars3.png images/lpd/orig/Cars4.png images/lpd/orig/Cars71.png images/lpd/orig/Cars87.png images/lpd/orig/Cars106.png images/lpd/orig/Cars143.png images/lpd/orig/Cars146.png images/lpd/orig/Cars249.png images/lpd/orig/Cars277.png images/lpd/orig/Cars295.png images/lpd/orig/Cars316.png images/lpd/orig/Cars330.png \
#                   images/lpd/orig/Cars5.png images/lpd/orig/Cars6.png images/lpd/orig/Cars9.png images/lpd/orig/Cars12.png images/lpd/orig/Cars14.png images/lpd/orig/Cars15.png images/lpd/orig/Cars23.png images/lpd/orig/Cars34.png images/lpd/orig/Cars37.png images/lpd/orig/Cars38.png images/lpd/orig/Cars46.png \
#                   images/lpd/orig"
                  "images/lpd/bmp/Cars0.bmp images/lpd/bmp/Cars1.bmp images/lpd/bmp/Cars2.bmp images/lpd/bmp/Cars3.bmp images/lpd/bmp/Cars4.bmp images/lpd/bmp/Cars71.bmp images/lpd/bmp/Cars87.bmp images/lpd/bmp/Cars106.bmp images/lpd/bmp/Cars143.bmp images/lpd/bmp/Cars146.bmp images/lpd/bmp/Cars249.bmp images/lpd/bmp/Cars277.bmp images/lpd/bmp/Cars295.bmp images/lpd/bmp/Cars316.bmp images/lpd/bmp/Cars330.bmp \
                   images/lpd/bmp/Cars5.bmp images/lpd/bmp/Cars6.bmp images/lpd/bmp/Cars9.bmp images/lpd/bmp/Cars12.bmp images/lpd/bmp/Cars14.bmp images/lpd/bmp/Cars15.bmp images/lpd/bmp/Cars23.bmp images/lpd/bmp/Cars34.bmp images/lpd/bmp/Cars37.bmp images/lpd/bmp/Cars38.bmp images/lpd/bmp/Cars46.bmp \
                   images/lpd/bmp"
                  "images/lpd/jpg/Cars0.jpg images/lpd/jpg/Cars1.jpg images/lpd/jpg/Cars2.jpg images/lpd/jpg/Cars3.jpg images/lpd/jpg/Cars4.jpg images/lpd/jpg/Cars71.jpg images/lpd/jpg/Cars87.jpg images/lpd/jpg/Cars106.jpg images/lpd/jpg/Cars143.jpg images/lpd/jpg/Cars146.jpg images/lpd/jpg/Cars249.jpg images/lpd/jpg/Cars277.jpg images/lpd/jpg/Cars295.jpg images/lpd/jpg/Cars316.jpg images/lpd/jpg/Cars330.jpg \
                   images/lpd/jpg/Cars5.jpg images/lpd/jpg/Cars6.jpg images/lpd/jpg/Cars9.jpg images/lpd/jpg/Cars12.jpg images/lpd/jpg/Cars14.jpg images/lpd/jpg/Cars15.jpg images/lpd/jpg/Cars23.jpg images/lpd/jpg/Cars34.jpg images/lpd/jpg/Cars37.jpg images/lpd/jpg/Cars38.jpg images/lpd/jpg/Cars46.jpg \
                   images/lpd/jpg"
                  "images/lpd/png/Cars0.png images/lpd/png/Cars1.png images/lpd/png/Cars2.png images/lpd/png/Cars3.png images/lpd/png/Cars4.png images/lpd/png/Cars71.png images/lpd/png/Cars87.png images/lpd/png/Cars106.png images/lpd/png/Cars143.png images/lpd/png/Cars146.png images/lpd/png/Cars249.png images/lpd/png/Cars277.png images/lpd/png/Cars295.png images/lpd/png/Cars316.png images/lpd/png/Cars330.png \
                   images/lpd/png/Cars5.png images/lpd/png/Cars6.png images/lpd/png/Cars9.png images/lpd/png/Cars12.png images/lpd/png/Cars14.png images/lpd/png/Cars15.png images/lpd/png/Cars23.png images/lpd/png/Cars34.png images/lpd/png/Cars37.png images/lpd/png/Cars38.png images/lpd/png/Cars46.png \
                   images/lpd/png")

declare -ar PERCENTAGE_LOADS=(25 50 75 100)
declare -ar ABSOLUTE_LOADS=(1 2 3 4 5 6 7 8 9)

export SLEDGE_SCHEDULER=EDF
export SLEDGE_DISABLE_PREEMPTION=false
export SLEDGE_SANDBOX_PERF_LOG=$(printf "lpd-perf-%i-%s-preemption_%s.csv" "$NWORKERS" "$SLEDGE_SCHEDULER" "$([[ $SLEDGE_DISABLE_PREEMPTION = false ]] && echo "true" || echo "false")")
export SLEDGE_NWORKERS=$NWORKERS

run_init
generate_spec_json
framework_init "$@"