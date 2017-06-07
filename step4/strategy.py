import networkx as nx
from networkx import algorithms
import pygraphviz as pgv

A_STATES = [
    ('c','c'),
    ('c','d'),
    ('d','c'),
    ('d','d')
]

BC_STATES = [
    (0, 0),
    (0, 1),
    (0, 2),
    (1, 0),
    (1, 1),
    (1,-1),
    (1, 2),
    (2, 0),
    (2, 1),
    (2, 2)
]

ALL_STATES = []
for a in A_STATES:
    for bc in BC_STATES:
        ALL_STATES.append( a+bc )

def state_to_index( state ):
    return ALL_STATES.index( state )

ALL_FULL_STATES = []
for a in A_STATES:
    for b in A_STATES:
        for c in A_STATES:
            ALL_FULL_STATES.append( a+b+c )

def full_state_to_index( full_state ):
    return ALL_FULL_STATES.index( full_state )

def full_state_to_str( full_state ):
    return ''.join(list(full_state))

def full_state_to_risk( full_state ):
    """returns -1,0,1 if the state is risky, neutral, exploitable."""
    if full_state[1] == 'c':
        if full_state[3] == 'c' and full_state[5] == 'c':  # => ccc
            return 0
        elif full_state[3] == 'd' and full_state[5] == 'd':  # => cdd
            return -2
        else:  # => ccd or cdc
            return -1
    else:
        if full_state[3] == 'd' and full_state[5] == 'd':  # => ddd
            return 0
        elif full_state[3] == 'c' and full_state[5] == 'c':  # => dcc
            return 2
        else:
            return 1

class Strategy:

    def __init__(self, actions):
        self.strategy = {}
        for (state,action) in zip(ALL_STATES,actions):
            self.strategy[state] = action

    def to_bits(self):
        actions = [ self.strategy[stat] for stat in ALL_STATES ]
        return "".join(actions)

    @classmethod
    def make_from_bits(cls, bits):
        actions = [ s for s in bits ]
        return cls(actions)

    def transition_graph(self):
        g = nx.DiGraph()
        for full_state in ALL_FULL_STATES:
            u = full_state_to_index(full_state)
            next_states = self._next_possible_full_states(full_state)
            for next_state in next_states:
                v = full_state_to_index(next_state)
                g.add_edge(u,v)
        return g

    def transition_graph_same_stra(self):
        g = nx.DiGraph()
        for full_state in ALL_FULL_STATES:
            u = full_state_to_index(full_state)
            next_state = self._next_state_with_same_strategy(full_state)
            v = full_state_to_index(next_state)
            g.add_edge(u,v)
        return g

    def to_dot(self,filename,g=None):
        f = open(filename,'w')
        f.write("digraph \"\" {\n")
        if g == None:
            g = self.transition_graph()
        for n in sorted(g.nodes()):
            stat = ALL_FULL_STATES[n]
            s = full_state_to_str(stat)
            risk = full_state_to_risk(stat)
            if risk == -2:
                color = "red"
            elif risk == -1:
                color = "orange"
            elif risk == 0:
                color = "black"
            elif risk == 1:
                color = "lightblue"
            elif risk == 2:
                color = "blue"
            f.write("  %d [ label=\"%d_%s\"; fontcolor = %s ];\n" % (n,n,s,color) )
        for o,d in sorted( g.edges(), key=lambda e: e[0] ):
        #for o,d in g.edges():
            f.write("  %d -> %d;\n" % (o,d) )
        f.write("}\n")
        f.close()

    def _next_possible_full_states(self,full_state):
        s = self._full_state_to_state(full_state)
        a_action = self.strategy[s]
        next_states = []
        for b_action in ['c','d']:
            for c_action in ['c','d']:
                s = (
                    full_state[1],
                    a_action,
                    full_state[3],
                    b_action,
                    full_state[5],
                    c_action
                )
                next_states.append(s)
        return next_states

    def _next_state_with_same_strategy(self, full_state):
        sa = self._full_state_to_state(full_state)
        a_action = self.strategy[sa]
        fs_b = (full_state[2],full_state[3],full_state[0],full_state[1],full_state[4],full_state[5])
        fs_c = (full_state[4],full_state[5],full_state[0],full_state[1],full_state[2],full_state[3])
        sb = self._full_state_to_state(fs_b)
        sc = self._full_state_to_state(fs_c)
        b_action = self.strategy[sb]
        c_action = self.strategy[sc]
        next_state = (full_state[1],a_action,full_state[3],b_action,full_state[5],c_action)
        return next_state

    def _full_state_to_state(self, full):
        if full[2] == 'd' and full[4] == 'd':
            s2 = 2
        elif full[2] == 'd' or full[4] == 'd':
            s2 = 1
        else:
            s2 = 0

        if full[3] == 'd' and full[5] == 'd':
            s3 = 2
        elif full[3] == 'd' or full[5] == 'd':
            s3 = 1
            if s2 == 1:
                if full[2] == 'd' and full[3] == 'd': s3 = -1
                if full[4] == 'd' and full[5] == 'd': s3 = -1
        else:
            s3 = 0

        state = ( full[0], full[1], s2, s3 )
        return state

    def has_risky_SCC(self):
        if self.risky_SCC():
            return True
        else:
            return False

    def risky_SCC(self):
        """returns a risky SCC. Used mainly for visualization"""
        g = self.transition_graph()
        good_nodes = [full_state_to_index(s) for s in ALL_FULL_STATES if full_state_to_risk(s) > 0]
        #print(good_nodes)
        g.remove_nodes_from(good_nodes)
        for component in nx.strongly_connected_components(g):
            if self._has_risky_loop_in_component(g, component):
                return component
        return None

    def _has_risky_loop_in_component(self,g,component):
        if len(component) > 1:
            states = [ ALL_FULL_STATES[n] for n in component ]
            risks = [ full_state_to_risk(s) for s in states ]
            if any( r < 0 for r in risks ):
                return True
            else:
                return False
        else:
            n = list(component)[0]
            stat = ALL_FULL_STATES[n]
            if full_state_to_risk(stat) >= 0:
                return False
            for org,dst in g.edges([n]):
                if org == dst:  # risky self loop
                    return True
            return False

if __name__ == '__main__':
    import sys
    def main():
        print( ALL_STATES )

        print( "cd02: %d" % state_to_index(('c','d',0,2)) )
        print( "dd22: %d" % state_to_index(('d','d',2,2)) )

        bits = "ccccdddcdddccccddcdddccccddcddcccccddddd"
        stra = Strategy.make_from_bits(bits)
        print(stra)
        print(stra.to_bits())
        assert stra.to_bits() == bits
        g = stra.transition_graph()
        print("%d nodes, %d edges in the transition graph" % (len(g.nodes()), len(g.edges())))
        stra.to_dot('foo.dot')

        #for (i,cycle) in enumerate(algorithms.simple_cycles(g)):
        #    if (i % 10000) == 0:
        #        print("%d"%i)

        #print("ALL_EXPLICIT_STATES: ", ALL_FULL_STATES, len(ALL_FULL_STATES) )
    main()

