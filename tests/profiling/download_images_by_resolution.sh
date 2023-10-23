declare -r width=64
declare -r height=64
declare -r n=1000
declare -r directory="images/picsum"

image_directory="$directory/${width}x${height}"
mkdir "$directory"
mkdir "$image_directory"

for ((i=1; i<=n; i++)); do
    echo "$i"
    url="https://picsum.photos/$width/$height"
    file="$image_directory/$i.jpg"
    curl -s -L -o "$file" "$url"
done