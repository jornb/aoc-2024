#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/haskell haskell /code/part${1:-1}.hs < ${2:-input}.txt
