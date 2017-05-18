require 'pp'
require_relative 'graph'

A_STATES = [
    [:c,:c],
    [:c,:d],
    [:d,:c],
    [:d,:d]
]

# Since either B or C is allD, the states cannot be [*,0] or [0,*], or [1,1].
BC_STATES = [
    #[0,0],
    #[0,1],
    #[0,2],
    #[1,0],
    #[1,1],
    [1,-1],
    [1,2],
    #[2,0],
    [2,1],
    [2,2]
]

STATES = []
A_STATES.each do |a|
  BC_STATES.each do |b|
    STATES << a+b
  end
end
pp "STATES : ", STATES

FIXED_STRATEGY = {
    [:d,:d,2, 2] => :d,
    [:d,:d,2, 1] => :d,
    [:d,:d,1, 2] => :d,
    [:d,:d,1,-1] => :d,
    [:c,:d,2, 2] => :d,
    [:c,:d,1,-1] => :d,
    [:c,:c,2, 2] => :d,
    [:c,:c,1,-1] => :d,
    [:c,:c,0, 0] => :c,
    [:c,:c,1, 1] => :d,
    [:c,:d,1, 2] => :d,
    [:c,:d,2, 1] => :d
}

UNFIXED_STATES = STATES - FIXED_STRATEGY.keys
# pp "UNFIXED_STATES: ", UNFIXED_STATES

strategy_candidates = [FIXED_STRATEGY]
UNFIXED_STATES.each do |state|
  copy1 = Marshal.load( Marshal.dump( strategy_candidates ) )
  copy1.each {|strategy| strategy[state] = :c }
  copy2 = Marshal.load( Marshal.dump( strategy_candidates ) )
  copy2.each {|strategy| strategy[state] = :d }
  strategy_candidates = copy1 + copy2
end

#pp strategy_candidates
pp strategy_candidates.size

def possible_next_states( strategy, stat )
  next_stat = [nil, nil, nil, nil]
  next_stat[0] = stat[1]
  next_stat[2] = (stat[3]!=-1) ? stat[3] : 1

  next_stat[1] = strategy[stat]

  if next_stat[2] == 1
    possible_states = [-1,2].map do |act_bc|
      next_stat[3] = act_bc
      next_stat.dup
    end
  else
    possible_states = [1,2].map do |act_bc|
      next_stat[3] = act_bc
      next_stat.dup
    end
  end
  possible_states
end

def construct_transition_graph(strategy)
  g = DirectedGraph.new( STATES.size )
  #pp strategy
  STATES.each_with_index do |stat,idx|
    next_states = possible_next_states( strategy, stat )
    #pp "stat", stat, "next_stat", next_states
    next_indexes = next_states.map {|next_stat| STATES.index(next_stat) }
    #pp next_indexes
    next_indexes.each do |n|
      g.add_link(idx, n)
    end
  end
  g
end

defensible_count = 0
defensible_strategies = []
strategy_candidates.each do |str|
  g = construct_transition_graph(str)
  #pp g
  risky_state = g.non_transient_nodes.find do |n|
    s = STATES[n]
    !(s[0] == :d and s[1] == :d)
  end
  #pp "risky_state : #{risky_state}"
  is_defensible = risky_state.nil?
  #$stderr.puts "strategy #{str} is #{is_defensible ? 'defensible':'non-defensible'}"
  defensible_strategies << str if is_defensible
  #break #TODO : remove later
end

def strategy_to_bits( strategy )
  acts
end

pp "# defensible : #{defensible_strategies.count}"
#pp defensible_strategies

pp "possible actions for states: ", UNFIXED_STATES
pp "must be one of the following"
pp defensible_strategies.map {|str|
    UNFIXED_STATES.map do |s|
      str[s]
    end
  }

