#!/bin/bash

declare -r directory="images/gocr"
declare -r font="mono"
declare -r words=10
declare -ar resolutions=(72 108 144)
declare -r number_images=100

for i in $(seq $number_images); do

shuf -n "$words" /usr/share/dict/american-english > "${directory}/${font}/${words}/${i}.txt"
for resolution in ${resolutions[*]}; do
  pango-view --dpi="$resolution" --font="$font" -qo "${directory}/${font}/${words}/${resolution}dpi/${i}.png" "${directory}/${font}/${words}/${i}.txt"
  pngtopnm "${directory}/${font}/${words}/${resolution}dpi/${i}.png" > "${directory}/${font}/${words}/${resolution}dpi/${i}.pnm"
done

done