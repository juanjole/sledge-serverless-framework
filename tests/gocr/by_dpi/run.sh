#!/bin/bash

__run_sh__base_path="$(dirname "$(realpath --logical "${BASH_SOURCE[0]}")")"
__run_sh__bash_libraries_relative_path="../../bash_libraries"
__run_sh__bash_libraries_absolute_path=$(cd "$__run_sh__base_path" && cd "$__run_sh__bash_libraries_relative_path" && pwd)
export PATH="$__run_sh__bash_libraries_absolute_path:$PATH"

source csv_to_dat.sh || exit 1
source framework.sh || exit 1
source get_result_count.sh || exit 1
source panic.sh || exit 1
source path_join.sh || exit 1
source percentiles_table.sh || exit 1
source validate_dependencies.sh || exit 1

experiment_client() {
	local -ri iteration_count=100
	local -ri word_count=100

	if (($# != 2)); then
		panic "invalid number of arguments \"$1\""
		return 1
	elif [[ -z "$1" ]]; then
		panic "hostname \"$1\" was empty"
		return 1
	elif [[ ! -d "$2" ]]; then
		panic "directory \"$2\" does not exist"
		return 1
	fi

	local -r hostname="$1"
	local -r results_directory="$2"

	# Perform Experiments
	printf "Running Experiments\n"
	local -ar dpis=(72 108 144)
	local -Ar dpi_to_path=(
		[72]=/gocr_72_dpi
		[108]=/gocr_108_dpi
		[144]=/gocr_144_dpi
	)
	local words
	for ((i = 0; i < iteration_count; i++)); do
		words="$(shuf -n"$word_count" /usr/share/dict/american-english)"

		for dpi in "${dpis[@]}"; do
			pango-view --dpi="$dpi" --font=mono -qo "${dpi}"_dpi.png -t "$words"
			pngtopnm "${dpi}"_dpi.png > "${dpi}"_dpi.pnm

			result=$(curl -H 'Expect:' -H "Content-Type: text/plain" --data-binary @"${dpi}"_dpi.pnm "$hostname:10000${dpi_to_path[$dpi]}" --silent -w "%{stderr}%{time_total}\n" 2>> "$results_directory/${dpi}_time.txt")

			rm "${dpi}"_dpi.png "${dpi}"_dpi.pnm

			# Logs the number of words that don't match
			echo "word count: $word_count" >> "$results_directory/${dpi}_full_results.txt"
			diff -ywBZE --suppress-common-lines <(echo "$words") <(echo "$result") \
				| tee -a "$results_directory/${dpi}_full_results.txt" \
				| wc -l >> "$results_directory/${dpi}_results.txt"
			echo "==========================================" >> "$results_directory/${dpi}_full_results.txt"
		done
	done

	# Process Results
	# Write Headers to CSV files
	printf "DPI,Success_Rate\n" >> "$results_directory/success.csv"
	percentiles_table_header "$results_directory/latency.csv" "dpi"

	for dpi in "${dpis[@]}"; do
		# Skip empty results
		oks=$(wc -l < "$results_directory/${dpi}_time.txt")
		((oks == 0)) && continue

		# Calculate success rate
		awk '
			BEGIN {total_mistakes=0}
			{total_mistakes += $1}
			END {
				average_mistakes = (total_mistakes / NR)
				success_rate = ('$word_count' - average_mistakes) / '$word_count' * 100
				printf  "'"$dpi"',%f\n", success_rate
			}
		' < "$results_directory/${dpi}_results.txt" >> "$results_directory/success.csv"

		# Convert latency from s to ms, and sort
		awk -F, '{print ($0 * 1000)}' < "$results_directory/${dpi}_time.txt" | sort -g > "$results_directory/${dpi}_time_sorted.txt"

		# Generate Latency Data for csv
		percentiles_table_row "$results_directory/${dpi}_time_sorted.txt" "$results_directory/latency.csv" "$dpi"

	done

	# Transform csvs to dat files for gnuplot
	csv_to_dat "$results_directory/success.csv" "$results_directory/latency.csv"
}

# Validate that required tools are in path
validate_dependencies curl shuf pango-view pngtopnm diff

framework_init "$@"
