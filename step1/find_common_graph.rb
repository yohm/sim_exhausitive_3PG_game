require 'pp'
require_relative 'strategy'

unless ARGV.size == 1
  $stderr.puts "[usage] ruby #{__FILE__} strategies.txt"
  raise "invalid argument"
end


graphs = File.open(ARGV[0]).map do |line|
  str = Strategy.make_from_bits(line.chomp)
  str.transition_graph_with_self
end

g = graphs.inject {|memo,g| DirectedGraph.common_subgraph(memo,g) }

node_attributes = {}
64.times do |i|
  fs = FullState.make_from_id(i)
  node_attributes[i] = {}
  node_attributes[i][:label] = "#{i}_#{fs.to_s}"
end
g.to_dot($stdout, remove_isolated: true, node_attributes: node_attributes)

node_sets = graphs.map do |g|
  nodes = []
  64.times do |i|
    nodes.push(i) if g.is_accessible?(i,0)
  end
  nodes
end
common_nodes = node_sets.inject {|memo,nodes| memo & nodes }
p common_nodes, common_nodes.size

node_sets = graphs.map do |g|
  nodes = []
  64.times do |i|
    nodes.push(i) if g.is_accessible?(i,63)
  end
  nodes
end
common_nodes = node_sets.inject {|memo,nodes| memo & nodes }
p common_nodes, common_nodes.size
