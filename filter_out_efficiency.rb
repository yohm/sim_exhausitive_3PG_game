require 'pp'
require_relative 'graph'

A_STATES = [
    [:c,:c],
    [:c,:d],
    [:d,:c],
    [:d,:d]
]

# Let us consdier that Alice had a noise.
# The state for Alice is (CD,00) while the state for the others are (CC01).
# The state must reach (CC,00) by a deterministic way.
# Since B&C take the same action, 
#
BC_STATES = [
    [0,0],
    [0,1],
    [0,2],
    [1,0],
    #[1,1],
    [1,-1],
    #[1,2],
    [2,0],
    #[2,1],
    [2,2]
]

STATES = []
A_STATES.each do |a|
  BC_STATES.each do |b|
    STATES << a+b
  end
end
pp "STATES : ", STATES, STATES.size

FIXED_STRATEGY = {
    [:d,:d,2, 2] => :d,
    #[:d,:d,2, 1] => :d,
    #[:d,:d,1, 2] => :d,
    [:d,:d,1,-1] => :d,
    [:c,:d,2, 2] => :d,
    [:c,:d,1,-1] => :d,
    #[:c,:d,1, 2] => :d,
    [:c,:c,2, 2] => :d,
    #[:c,:d,2, 1] => :d,
    [:c,:c,1,-1] => :d,
    [:c,:c,0, 0] => :c,
    [:c,:c,1, 1] => :d
}

UNFIXED_STATES = STATES - FIXED_STRATEGY.keys
# pp "UNFIXED_STATES: ", UNFIXED_STATES

strategy_candidates = [FIXED_STRATEGY]
UNFIXED_STATES.each do |state|
  copy1 = Marshal.load( Marshal.dump( strategy_candidates ) )
  copy1.each {|strategy| strategy[state] = :c }
  strategy_candidates = copy1
  if strategy_candidates.size < 65536
    copy2 = Marshal.load( Marshal.dump( strategy_candidates ) )
    copy2.each {|strategy| strategy[state] = :d }
    strategy_candidates += copy2
  end
end

#pp strategy_candidates
pp strategy_candidates.size

def reaches_cc_from_1bit_noise?(str)
  a_state =  [:c,:d,0,0]
  bc_state = [:c,:c,0,1]
  raise "must not happen" if a_state.nil? or bc_state.nil?

  a_state_history = [ a_state.dup ]
  loop do
    a_action = str[ a_state ]
    bc_action = str[ bc_state ]
    #pp "a_state : ", a_state
    #pp "bc_state : ", bc_state
    #pp "a_action : ", a_action
    #pp "bc_action : ", bc_action

    a_state[0] = a_state[1]
    a_state[2] = a_state[3]
    a_state[1] = a_action
    a_state[3] = (bc_action==:d ? 2 : 0)

    bc_state[0] = bc_state[1]
    bc_state[2] = bc_state[3]
    bc_state[1] = bc_action
    if a_action == :d
      if bc_action == :d
        bc_state[3] = 2
      else  # bc_action == :c
        bc_state[3] = 1
        bc_state[3] = -1 if a_state[0] == :d # consecutive defection
      end
    else  # :a_action == :c
      if bc_action == :d
        bc_state[3] = 1
        bc_state[3] = -1 if a_state[0] == :c # consecutive defection
      else  # bc_action == :c
        bc_state[3] = 0
      end
    end

    # check loop
    break if a_state_history.include?( a_state ) # we reached a loop
    a_state_history << a_state.dup
  end

  pp "final a_state: ", a_state
  a_state == [:c,:c,0,0]
end

efficient_strategies = strategy_candidates.select do |str|
  reaches_cc_from_1bit_noise?(str)
end

pp efficient_strategies.size
