#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/d-dmd d-dmd /code/part${1:-1}.d < ${2:-input}.txt
