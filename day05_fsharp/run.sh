#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/fsharp-dotnet fsharp-dotnet /code/part${1:-1}.fs < ${2:-input}.txt
