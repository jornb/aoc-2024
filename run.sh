#!/usr/bin/env bash
set -e

day=$1
part=${2:-1}
input_filename=${3:-input}

# Prepand 0 if day is < 10
if [ ${#day} -eq 1 ]; then
    day="0$day"
fi


folder=$(find -name "day${day}_*" -type d)

# Get the language from the folder name, on the format dayXX_language
language=$(echo $folder | cut -d'_' -f2)

ext=""
container=""
command=""
case $language in
    ada)
        ext="adb"
        container="esolang/ada"
        command="ada"
        ;;
    bash)
        ext="bash"
        container="esolang/bash-busybox"
        command="bash-busybox"
        ;;
    crystal)
        ext="cr"
        container="esolang/crystal"
        command="crystal"
        ;;
    d)
        ext="d"
        container="esolang/d-dmd"
        command="d-dmd"
        ;;
    elixir)
        ext="ex"
        container="esolang/elixir"
        command="elixir"
        ;;
    fsharp)
        ext="fs"
        container="esolang/fsharp-dotnet"
        command="fsharp-dotnet"
        ;;
    go)
        ext="go"
        container="esolang/golang"
        command="golang"
        ;;
    haskell)
        ext="hs"
        container="esolang/haskell"
        command="haskell"
        ;;
    *)
        echo "Unsupported language: $language"
        exit 1
        ;;
esac

if [ -n "$container" ]; then
    cd $folder
    docker run --rm -i -v "$PWD":/code:ro $container $command /code/part$part.$ext < $input_filename.txt
fi
