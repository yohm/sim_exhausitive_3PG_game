require 'pp'
require_relative 'strategy'

unless ARGV.size == 1
  $stderr.puts "[usage] ruby #{__FILE__} strategies.txt"
  raise "invalid argument"
end


strategies = File.open(ARGV[0]).map do |line|
  Strategy.make_from_bits(line.chomp)
end

links_arrays = strategies.map do |str|
  g = str.transition_graph_with_self
  links = []
  g.for_each_link do |ni,nj|
    links << [ni,nj]
  end
  links
end

common_links = links_arrays.inject {|memo,links| memo & links }

g = DirectedGraph.new(64)
common_links.each do |link|
  g.add_link(*link)
end
node_attributes = {}
64.times do |i|
  fs = FullState.make_from_id(i)
  node_attributes[i] = {}
  node_attributes[i][:label] = "#{i}_#{fs.to_s}"
end
g.to_dot($stdout, remove_isolated: true, node_attributes: node_attributes)

