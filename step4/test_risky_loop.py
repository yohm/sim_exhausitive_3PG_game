import strategy
import networkx as nx

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
