# exhaustive enumeration of successful strategies for three-person public goods game

The first step is defensibility against allD.

```
ruby filter_out_allD.rb
```

The command will print all defensible (sub)strategies against the allD strategy.
It will print 48 sub-strategies.

In addition to this, we can fix the bits by efficiency condition, distinguishability condition, and defensibility against (**,11).
After these bits are fixed, we have 3/4*3/4*2^28 possible strategies.

To print all these strategies, run the following command.

```
ruby strategy_enumerator.rb
```

It will create "step1" directory, and then print out strategies in "bit" format into multiple files.
By default, the number of files is set to 384.

Then, we filter out these strategies by efficiency condition.
To fulfill the efficiency condition, three persons must reach cooperating state from the state disturbed by 1 bit in deterministic way.
The following command will filter out the strategies in step1 and print them out into the files in "step2" directory.

```
ls step1/bits*.txt | xargs -n 1 -P 6 time ruby filter_out_efficiency.rb
```

The option "-P" controls the number of parallel processes. Change this number depending on your environment.


