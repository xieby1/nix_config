#!/usr/bin/env bash

dir="$1"
while true; do
    echo $dir

    dirdir=$(dirname "$dir")
    if [[ "$dir" != "$dirdir" ]]; then
        dir="$dirdir"
    else
        break
    fi
done
