require 'pp'

class DirectedGraph

  attr_reader :n, :links

  def initialize(size)
    @n = size
    @links = Hash.new {|hsh,key| hsh[key] = Array.new }
  end

  def add_link( from, to )
    raise "invalid index: #{from}->#{to}" unless from < @n and to < @n
    @links[from].push(to)
  end

  def sccs
    f = ComponentFinder.new(self)
    f.strongly_connected_components
  end

  def transient_nodes
    isolated_nodes = sccs.select {|scc| scc.size == 1 }.flatten
    has_selfloop = isolated_nodes.select do |n|
      @links[n].include?(n)
    end
    isolated_nodes - has_selfloop
  end

  def non_transient_nodes
    (0..(@n-1)).to_a - transient_nodes
  end

  def remove_duplicated_links!
    @links.values.each {|ns| ns.uniq! }
  end

  def to_dot(io, node_attributes: {}, remove_isolated: false, node_ranks: [])
    io.puts "digraph \"\" {"
    @n.times do |ni|
      next if remove_isolated and @links[ni].empty?
      label = node_attributes.dig(ni,:label) || ni.to_s
      fontcolor = node_attributes.dig(ni,:fontcolor) || "black"
      io.puts "  #{ni} [ label=\"#{label}\"; fontcolor = #{fontcolor} ];"
    end
    @n.times do |ni|
      next if remove_isolated and @links[ni].empty?
      @links[ni].each do |nj|
        io.puts "  #{ni} -> #{nj};"
      end
    end
    if node_ranks.size > 0
      ranks = node_ranks.map.with_index {|_,i| "rank_#{i}"}
      io.puts "  #{ranks.join(' -> ')}"
      node_ranks.each_with_index do |nodes,i|
        io.puts "  {rank=same; #{ranks[i]}; #{nodes.join(';')};}"
      end
    end
    io.puts "}"
    io.flush
  end

  def is_accessible?(from, to)
    found = false
    bfs(from) {|n|
      found = true if n == to
    }
    found
  end

  def for_each_link
    @n.times do |ni|
      @links[ni].each do |nj|
        yield ni, nj
      end
    end
  end

  def bfs(start, &block)
    stuck=[]
    bfs_impl = lambda do |n|
      block.call(n)
      stuck.push(n)
      @links[n].each do |nj|
        next if stuck.include?(nj)
        bfs_impl.call(nj)
      end
    end
    bfs_impl.call(start)
  end

  def self.common_subgraph(g1,g2)
    g = self.new( g1.n )
    links1 = []
    g1.for_each_link {|ni,nj| links1.push( [ni,nj] ) }
    links2 = []
    g2.for_each_link {|ni,nj| links2.push( [ni,nj] ) }
    common_links = links1 & links2
    common_links.each {|l| g.add_link(*l) }
    g
  end
end

class ComponentFinder

  def initialize( graph )
    @g = graph
    @t = 0

    @desc =  Array.new(@g.n, nil)
    @low  =  Array.new(@g.n, nil)
    @stack = []
    @on_stack  =  Array.new(@g.n, false)
  end

  def strongly_connected_components
    @sccs = []
    @g.n.times do |v|
      if @desc[v].nil?
        strong_connect(v)
      end
    end
    @sccs
  end

  private
  def strong_connect(v)
    @desc[v] = @t
    @low[v] = @t
    @t += 1

    @stack.push(v)
    @on_stack[v] = true

    @g.links[v].each do |w|
      if @desc[w].nil?
        strong_connect(w)
        @low[v] = @low[w] if @low[w] < @low[v]
      elsif @on_stack[w]
        @low[v] = @desc[w] if @desc[w] < @low[v]
      end
    end

    # if v is a root node, pop the stack and generate an scc
    scc = []
    if @low[v] == @desc[v]
      loop do
        w = @stack.pop
        @on_stack[w] = false
        scc.push(w)
        break if v == w
      end
      @sccs.push( scc )
    end
  end
end

if __FILE__ == $0
  g1 = DirectedGraph.new(5)
  g1.add_link(1, 0)
  g1.add_link(0, 2)
  g1.add_link(2, 1)
  g1.add_link(0, 3)
  g1.add_link(3, 4)
  g1.add_link(4, 4)
  pp g1
  pp g1.sccs  #=> [ [0,1,2], [3], [4] ]
  pp g1.transient_nodes  # [3]
  pp g1.non_transient_nodes  # [0,1,2,4]
  g1.to_dot($stdout)

  g1.bfs(0) {|n| p n}
  p g1.is_accessible?(0,4) # => true
  p g1.is_accessible?(3,0) # => false
end

