require 'pp'

A_STATES = [
    [:c,:c],
    [:c,:d],
    [:d,:c],
    [:d,:d]
]

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
    [:c,:c,1,-1] => :d
    #[:c,:c,0, 0] => :c
}

UNFIXED_STATES = STATES - FIXED_STRATEGY.keys
pp "UNFIXED_STATES: ", UNFIXED_STATES

strategy_candidate = []
[:c,:d].product( [:c,:d],[:c,:d],[:c,:d],[:c,:d],[:c,:d],[:c,:d],[:c,:d] ) do |actions|
  pp actions
  s = FIXED_STRATEGY.merge( Hash[ UNFIXED_STATES.zip(actions) ] )
  strategy_candidate << s
end

pp strategy_candidate
pp strategy_candidate.size

=begin
class Strategy

  def initialize(actions)
    @actions = actions
    @graph = transition_graph
  end

  def transition_graph
    # IMPLEMENT ME
  end

  def defensible_against_alld?
    @graph.find_all_loops.all? do |loop|
      contain_dd_only?(loop)
    end
  end
end

found = possible_strategies.find_all do |s|
  s.defensible_against_alld?
end
pp found
=end
