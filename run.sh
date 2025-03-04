#!/usr/bin/env bash
set -e

day=$1
part=${2:-1}
input_filename=${3:-input}

# Prepand 0 if day is < 10
if [ ${#day} -eq 1 ]; then
    day="0$day"
fi


folder=$(find -maxdepth 1 -name "day${day}_*" -type d)

# Get the language from the folder name, on the format dayXX_language
language=$(echo $folder | cut -d'_' -f2)

ext=""
image=""
command=""
case $language in
    ada)
        ext="adb"
        image="esolang/ada"
        command="ada"
        ;;
    bash)
        ext="bash"
        image="esolang/bash-busybox"
        command="bash-busybox"
        ;;
    crystal)
        ext="cr"
        image="esolang/crystal"
        command="crystal"
        ;;
    d)
        ext="d"
        image="esolang/d-dmd"
        command="d-dmd"
        ;;
    elixir)
        ext="ex"
        image="esolang/elixir"
        command="elixir"
        ;;
    fsharp)
        ext="fs"
        image="esolang/fsharp-dotnet"
        command="fsharp-dotnet"
        ;;
    go)
        ext="go"
        image="esolang/golang"
        command="golang"
        ;;
    haskell)
        ext="hs"
        image="esolang/haskell"
        command="haskell"
        ;;
    io)
        ext="io"
        command="io"
        ;;
    java)
        ext="java"
        image="esolang/java"
        command="java"
        ;;
    kotlin)
        ext="kt"
        image="esolang/kotlin"
        command="kotlin"
        ;;
    lua)
        ext="lua"
        image="esolang/lua"
        command="lua"
        ;;
    matlab)
        ext="m"
        image="esolang/octave"
        command="octave"
        ;;
    nim)
        ext="nim"
        image="esolang/nim-lang"
        command="nim-lang"
        ;;
    octave)
        ext="m"
        image="esolang/octave"
        command="octave"
        ;;
    python)
        ext="py"
        image="esolang/python3"
        command="python3"
        ;;
    rust)
        ext="rs"
        image="esolang/rust"
        command="rust"
        ;;
    ruby)
        ext="rb"
        image="esolang/ruby"
        command="ruby"
        ;;
    swift)
        ext="swift"
        image="esolang/swift"
        command="swift"
        ;;
    scala)
        ext="scala"
        command="./run"
        ;;
    typescript)
        ext="ts"
        command="./run"
        ;;
    cpp)
        ext="cpp"
        command="./run"
        ;;
    v)
        ext="v"
        image="esolang/vlang"
        command="vlang"
        ;;
    php)
        ext="php"
        image="esolang/php"
        command="php"
        ;;
    julia)
        ext="jl"
        image="julia:1-bookworm"
        command="julia"
        ;;
    zig)
        ext="zig"
        image="esolang/zig"
        command="zig"
        ;;
    dart)
        ext="dart"
        image="dart:3.5"
        command="dart run"
        ;;
    *)
        echo "Unsupported language: $language"
        exit 1
        ;;
esac

# If the image doesn't exist, build it from Dockerfile
if [ -z "$image" ] && [ -f "$folder/Dockerfile" ]; then
    image="aoc-$language"
    docker build -t $image -f $folder/Dockerfile $folder
fi

if [ -n "$image" ]; then
    cd $folder
    docker run --rm --name aoc -i -v "$PWD":/code:ro $image $command /code/part$part.$ext < $input_filename.txt
fi
