#!/bin/bash

declare -r directory="images/gocr"
declare -r font="roboto"
declare -ar words=($(seq 10 1 30))
declare -ar resolutions=(72 108 144)
declare -r number_images=100

for number_words in ${words[*]}; do

for i in $(seq $number_images); do

mkdir -p "${directory}/${font}/${number_words}/txt"
shuf -n "$number_words" /usr/share/dict/american-english > "${directory}/${font}/${number_words}/txt/${i}.txt"

for resolution in ${resolutions[*]}; do
  mkdir -p "${directory}/${font}/${number_words}/${resolution}dpi/png"
  pango-view --dpi="$resolution" --font="$font" -qo "${directory}/${font}/${number_words}/${resolution}dpi/png/${i}.png" "${directory}/${font}/${number_words}/txt/${i}.txt"
  mkdir -p "${directory}/${font}/${number_words}/${resolution}dpi/pnm"
  pngtopnm "${directory}/${font}/${number_words}/${resolution}dpi/png/${i}.png" > "${directory}/${font}/${number_words}/${resolution}dpi/pnm/${i}.pnm"
done

done

done