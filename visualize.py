import strategy
import sys
import subprocess

if len(sys.argv) != 2:
    print(sys.argv)
    sys.stderr.write("invalid argument\n")
    sys.stderr.write("Usage: python visualize.py [strategy]")
    raise "invalid argument"

bits = sys.argv[1]
stra = strategy.Strategy.make_from_bits(bits)
print(stra.to_bits())

stra.to_dot("temp.dot")
cmd = "dot -K fdp -T pdf temp.dot -o temp.pdf"
subprocess.run(cmd, shell=True, check=True)

