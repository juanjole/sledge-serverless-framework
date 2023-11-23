declare -r image_directory="images/cifar10"
declare -ar resolutions=("32x32" "64x64")
declare -ar formats=("bmp" "jpg" "png")
declare -ar initial_ports=(10000 20000 30000)
declare -ar classes=("any" "cat" "ship" "airplane" "frog" "automobile" "airplane" "truck" "dog" "horse" "deer")
declare -r target="localhost"
declare -r number_samples=200
declare -r loads=(1 2 3 4 5 6 7 8 9)

for format_idx in "${!formats[@]}"; do
  format=${formats[$format_idx]}
  initial_port=${initial_ports[$format_idx]}
  for resolution in ${resolutions[*]}; do
    for load in ${loads[*]}; do
      port=$((initial_port+load))
      for class in ${classes[*]}; do
        echo "Class: $class"
        endpoint=$(printf "%s:%i/cifar10-%s_%s_NaN" "$target" "$port" "$class" "$resolution")
        if [ "$class" = "any" ]; then
            files=("$image_directory"/"$resolution"_test/*."$format")
        else
            files=("$image_directory"/"$resolution"_test/*_"$class"."$format")
        fi
        number_files=${#files[*]}
        rand_files=($(shuf -e "${files[@]}"))
        file_index=0
        counter_samples=0
        while [ $counter_samples -lt $number_samples ]; do
          for _ in $(seq "$load"); do
            file=${rand_files[file_index]}
            curl -H 'Expect:' -H "Content-Type: text/plain" --data-binary @"$file" "$endpoint" &
            counter_samples=$((counter_samples+1))
            file_index=$((counter_samples % number_files))
          done
          wait
        done
      done
    done
  done
done
