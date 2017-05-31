import strategy
import sys
import subprocess
import networkx as nx

if len(sys.argv) != 2 and len(sys.argv) != 3:
    print(sys.argv)
    sys.stderr.write("invalid argument\n")
    sys.stderr.write("Usage: python visualize.py strategy [-1:risky scc,0:same_strategy")
    raise "invalid argument"

bits = sys.argv[1]
stra = strategy.Strategy.make_from_bits(bits)
print(stra.to_bits())

g = stra.transition_graph()

if len(sys.argv) == 3:
    n = int(sys.argv[2])
    if n == 0:
        g = stra.transition_graph_same_stra()
    else:
        risky_nodes = stra.risky_SCC()
        g = g.subgraph(risky_nodes)

stra.to_dot("temp.dot", g)
cmd = "dot -K fdp -T pdf temp.dot -o temp.pdf"
subprocess.run(cmd, shell=True, check=True)

