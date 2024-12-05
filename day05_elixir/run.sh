#!/usr/bin/env bash
set -e
cd $(dirname -- $0)
docker run --rm -i -v "$PWD":/code:ro esolang/elixir elixir /code/part${1:-1}.ex < ${2:-input}.txt
