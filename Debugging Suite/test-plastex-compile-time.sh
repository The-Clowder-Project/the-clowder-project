#!/bin/bash

# Hashes for plastex commits
hashes=(
    7821e5f
    b187cbd
    c57adef
    8a19eb0
    75c6239
    9a27544
    3ca41f9
    2127c51
    00b98f1
    767cc07
    aa122d3
    b8f4878
    d03acd3
    683cc94
    2b07908
    8c3513d
    5a77103
    22cfb6d
    fbc422f
    de87b5b
    c7776d0
    32e3227
    4de0887
    7e8ad83
    13baf0a
    aec7e53
    dac60d9
    b1bba70
    ff4c8e0
    ef75400
    4fb5631
    6c6678d
    fc0bf5a
    f1427dd
    6e421fb
    bd4c484
    3495431
    68d8f10
)

# cd out of "Debugging Suite" directory first
cd ../

# Loop through each commit
for item in "${hashes[@]}"; do
    # Installs plastex at commit $item
    cd plastex
    git checkout $item
    pip install --user .
    cd ../
    # Writes current hash
    echo -n $item >> log.log
    echo -n "," >> log.log
    for n in {1..15}; do
        make web-and-record
    done
    # Newline
    echo "" >> log.log
done
