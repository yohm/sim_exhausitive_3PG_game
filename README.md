# exhaustive enumeration of successful strategies for three-person public goods game

## Step 1

The first step is defensibility against allD.

```
ruby step1/filter_out_allD.rb
```

The command will print all defensible (sub)strategies against the allD strategy.
It will print 48 sub-strategies.

In addition to this, we can fix the bits by efficiency condition, distinguishability condition, and defensibility against (**,11).
After these bits are fixed, we have 3/4*3/4*2^28 possible strategies.

To print all these strategies, run the following command.

```
ruby step1/strategy_enumerator.rb step1_result
```

It will create "step1_result" file.
You should split the output into several files in order to use it in the following steps.

## Step 2

Then, we filter out these strategies by efficiency condition.
To fulfill the efficiency condition, three persons must reach cooperating state from the state disturbed by 1 bit in deterministic way.
The following command will filter out the strategies in step1_result and print them out into the files in "step2_result" directory.

```
ls step1_result/bits*.txt | xargs -n 1 -P 6 time ruby step2/filter_out_efficiency.rb step2_result
```

The option "-P" controls the number of parallel processes. Change this number depending on your environment.

## Step 3

We filtered out strategies using the efficiency condition.
We assume multiplication factor=2, cost=1, e=0.01, and calculated the expected payoff the player. Firstly, we removed the strategies whose payoff is less than 0.7, and got 236k strategies as a result.
For these, we further filtered out the strategies using e=0.005 and threshold=0.9. After that 30k strategies remained.

Although we tried to filter out some by Step 2, criteria for Step 3 is more strict. So we applied this filtering against the results of Step 1.

```
ls filtered*.txt | xargs -n 1 -P 6 -I{} -t sh -c '../step3/main.out 0.005 "$1" > "$1_out"' -- {}
```

