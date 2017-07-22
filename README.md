# exhaustive enumeration of successful strategies for three-person public goods game

## Step 1

The first step is defensibility against allD.

```
./ruby/bin/run_defensibility_check.sh
```

The files containing the strategies passing the AllD-defensibility check are created in "result_allD_checked".

## Step 2

Then, we filter out these strategies by the defensibility condition.

## Step 3

Then, we filter out strategies using the efficiency condition.

We assume multiplication factor=2, cost=1, e=0.01, and calculated the expected payoff the player. Firstly, we removed the strategies whose payoff is less than 0.7, and got 236k strategies as a result.
For these, we further filtered out the strategies using e=0.005 and threshold=0.9. After that 30k strategies remained.

Although we tried to filter out some by Step 2, criteria for Step 3 is more strict. So we applied this filtering against the results of Step 1.

```
ls filtered*.txt | xargs -n 1 -P 6 -I{} -t sh -c '../step3/main.out 0.005 "$1" > "$1_out"' -- {}
```

