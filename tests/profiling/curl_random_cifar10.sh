declare -r image_directory="images/cifar10"

declare -r files=("$image_directory"/*)

declare -ir concurrent_requests=3

declare number_files=${#files[*]}

rand_files=($(shuf -e "${files[@]}"))

loads=(1 2 3 4 5 6 7 8 9 10 15 25 50 100)

duration_secs=5
initial_port=10000
target="localhost"

for load in ${loads[*]}; do
  port=$((initial_port+load))
  endpoint=$(printf "%s:%i/cifar10" "$target" "$port")
  end_time=$((SECONDS+"$duration_secs"))
  file_index=0
  while [ $SECONDS -lt $end_time ]; do
    for _ in $(seq $concurrent_requests); do
      file=${rand_files[file_index]}
      curl -H 'Expect:' -H "Content-Type: text/plain" --data-binary @"$file" "$endpoint" &
      file_index=$(((file_index + 1) % number_files))
    done
    wait
  done
done
