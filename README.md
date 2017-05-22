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

It will create "step1" directory, and then print out strategies in "string" format into multiple files.
By default, the number of files is set to 384.

## Step 2

Then, we filter out these strategies by efficiency condition.
To fulfill the efficiency condition, three persons must reach cooperating state from the state disturbed by 1 bit in deterministic way.
The following command will filter out the strategies in step1_result and print them out into the files in "step2_result" directory.

```
ls step1_result/bits*.txt | xargs -n 1 -P 6 time ruby step2/filter_out_efficiency.rb step2_result
```

The option "-P" controls the number of parallel processes. Change this number depending on your environment.


