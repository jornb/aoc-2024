#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/crystal crystal /code/part${1:-1}.cr < ${2:-input}.txt
