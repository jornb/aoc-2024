#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/golang golang /code/part${1:-1}.go < ${2:-input}.txt
