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
end

