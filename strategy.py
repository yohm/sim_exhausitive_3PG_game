import networkx as nx
from networkx import algorithms

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

ALL_ABC_STATES = []
for a in A_STATES:
    for b in A_STATES:
        for c in A_STATES:
            ALL_ABC_STATES.append( a+b+c )

def abc_state_to_index( abc_state ):
    return ALL_ABC_STATES.index( abc_state )

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
        for abc_state in ALL_ABC_STATES:
            u = abc_state_to_index(abc_state)
            next_states = self._next_possible_abc_states(abc_state)
            for next_state in next_states:
                v = abc_state_to_index(next_state)
                g.add_edge(u,v)
        return g

    def _next_possible_abc_states(self,abc_state):
        s = self._abc_state_to_state(abc_state)
        a_action = self.strategy[s]
        next_states = []
        for b_action in ['c','d']:
            for c_action in ['c','d']:
                s = (
                    abc_state[1],
                    a_action,
                    abc_state[3],
                    b_action,
                    abc_state[5],
                    c_action
                )
                next_states.append(s)
        return next_states

    def _abc_state_to_state(self, abc):
        if abc[2] == 'd' and abc[4] == 'd':
            s2 = 2
        elif abc[2] == 'd' or abc[4] == 'd':
            s2 = 1
        else:
            s2 = 0

        if abc[3] == 'd' and abc[5] == 'd':
            s3 = 2
        elif abc[3] == 'd' or abc[5] == 'd':
            s3 = 1
            if s2 == 1:
                if abc[2] == 'd' and abc[3] == 'd': s3 = -1
                if abc[4] == 'd' and abc[5] == 'd': s3 = -1
        else:
            s3 = 0

        state = ( abc[0], abc[1], s2, s3 )
        return state


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
        for (i,cycle) in enumerate(algorithms.simple_cycles(g)):
            if (i % 10000) == 0:
                print("%d"%i)

        print("ALL_EXPLICIT_STATES: ", ALL_ABC_STATES, len(ALL_ABC_STATES) )
    main()

