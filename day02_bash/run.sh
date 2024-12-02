#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/bash-busybox bash-busybox /code/part${1:-1}.bash < ${2:-input}.txt