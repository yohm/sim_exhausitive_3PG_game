import strategy
import networkx as nx

#def _has_risky_loop_in_component(g,component):
#    if len(component) > 1:
#        states = [ strategy.ALL_FULL_STATES[n] for n in component ]
#        risks = [ strategy.full_state_to_risk(s) for s in states ]
#        if any( r < 0 for r in risks ):
#            return True
#        else:
#            return False
#    else:
#        n = list(component)[0]
#        stat = strategy.ALL_FULL_STATES[n]
#        if strategy.full_state_to_risk(stat) >= 0:
#            return False
#        for org,dst in g.edges([n]):
#            if org == dst:  # risky self loop
#                return True
#        return False
#
#def has_risky_SSC(stra):
#    g = stra.transition_graph()
#    good_nodes = [ strategy.full_state_to_index(s) for s in strategy.ALL_FULL_STATES if strategy.full_state_to_risk(s) > 0 ]
#    print( good_nodes )
#    g.remove_nodes_from(good_nodes)
#    print( sorted(list(g.nodes())) )
#
#    for component in nx.strongly_connected_components(g):
#        if _has_risky_loop_in_component(g, component):
#            print(component)
#            return True
#    return False

if __name__ == '__main__':
    import sys
    def main():
        if len(sys.argv) != 2:
            print(sys.argv)
            sys.stderr.write("invalid argument\n")
            sys.stderr.write("Usage: python visualize.py [strategy]")
            raise "invalid argument"

        infile = sys.argv[1]
        print(infile)
        f = open(infile, 'r')
        count = 0
        s = set(range(64))
        for line in f:
            bits = line.strip()
            stra = strategy.Strategy.make_from_bits(bits)
            b = stra.has_risky_SCC()
            scc = stra.risky_SCC()
            s = s.intersection(set(scc))
            print( stra.to_bits(), b, scc, s )
            count += 1
            if b == False:
                break
        print("done %d" % count)

    main()
