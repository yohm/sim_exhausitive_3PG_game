#!/bin/bash -eux

ruby filter_out_allD.rb > allD_pattern
cat allD_pattern | xargs -P 12 -n 1 -t -I{} sh -c 'ruby strategy_enumerator.rb "$1" > "$1_out"' -- {}
cat -- -*d_out > allD_checked
rm -f -- -*d_out
mkdir -p result_allD_checked
cd result_allD_checked
# 402_653_184 / 12 = 33554432
# spliting into 12 files
split -l 33554432 ../allD_checked ./allD_checked.
