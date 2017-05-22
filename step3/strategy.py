A_STATES = [
    ('C','C'),
    ('C','D'),
    ('D','C'),
    ('D','D')
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

mapped = [ "State( %s, %s, %d, %d )," % x for x in ALL_STATES ]
for s in mapped:
    print( s )
