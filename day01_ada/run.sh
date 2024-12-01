#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/ada ada /code/part${1:-1}.adb < ${2:-input}.txt
