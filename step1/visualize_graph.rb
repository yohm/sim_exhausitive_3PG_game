require_relative "strategy"

unless ARGV.size == 2
  $stderr.puts "[Error] Usage: ruby #{__FILE__} strategy_string output.pdf"
  raise "invalid argument"
end

stra = Strategy.make_from_bits(ARGV[0])
g = stra.transition_graph_with_self

node_attributes = {}
64.times do |i|
  fs = FullState.make_from_id(i)
  node_attributes[i] = {}
  node_attributes[i][:label] = "#{i}_#{fs.to_s}"
end

tmp = "temp.dot"
io = File.open(tmp, 'w')
g.to_dot( io, node_attributes: node_attributes )
io.close

cmd = "dot -K fdp -T pdf #{tmp} -o #{ARGV[1]}"
system(cmd)

