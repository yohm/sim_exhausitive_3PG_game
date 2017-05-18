require 'pp'

module State

  A_STATES = [
      [:c,:c],
      [:c,:d],
      [:d,:c],
      [:d,:d]
  ]

  BC_STATES = [
      [0,0],
      [0,1],
      [0,2],
      [1,0],
      [1,1],
      [1,-1],
      [1,2],
      [2,0],
      [2,1],
      [2,2]
  ]

  ALL_STATES = A_STATES.product(BC_STATES).map {|a,bc| (a+bc).freeze }.freeze

  def self.valid?(state)
    ALL_STATES.include?( state )
  end

  def self.index( state )
    ALL_STATES.index( state )
  end
end

class Strategy

  def initialize( actions )
    @strategy = Hash[ State::ALL_STATES.zip( actions ) ]
  end

  def to_bits
    State::ALL_STATES.map do |stat|
      @strategy[stat] == :c ? 'c' : 'd'
    end.join
  end

  def valid?
    @strategy.values.all? {|a| a == :c or a == :d }
  end
end

class StrategyEnumerator

  def initialize
    n = State::ALL_STATES.size
    @fixed_actions = {}
  end

  def set_fixed_action( state, action )
    @fixed_actions[ state ] = action
  end

  def fixed_actions_to_bit
    State::ALL_STATES.map do |stat|
      @fixed_actions[stat] || '-'
    end.join
  end

  def all_strategy
    all_states = State::ALL_STATES
    e = Enumerator.new do |y|
      # set fixed actions
      actions = Array.new( all_states.size, nil )
      @fixed_actions.each do |stat, act|
        idx = State.index(stat)
        actions[idx] = act
      end

      unfixed_states = all_states - @fixed_actions.keys
      unfixed_state_indexes = unfixed_states.sort.map {|stat| State.index(stat) }

      iterate_for = lambda do |idx|
        stat_idx = unfixed_state_indexes[idx]
        [:c,:d].each do |act|
          actions[stat_idx] = act
          if idx < unfixed_state_indexes.size-1
            iterate_for.call( idx+1 )
          else
            #pp stat_idx
            y << Strategy.new(actions)
          end
        end
      end

      iterate_for.call( 0 )
    end
    e
  end
end

if __FILE__ == $0
  #State.all.each {|s| p s}
  p State::ALL_STATES
  p State::ALL_STATES.size
  p s = Strategy.new( [:c,:d]*20 )
  p s.valid?
  p se = StrategyEnumerator.new
  count = 0
  FIXED_ACTIONS = {
      [:d,:d,2,2] => :d,
      [:d,:d,2,1] => :d,
      [:d,:d,1,2] => :d,
      [:d,:d,1,-1] => :d,
      [:c,:d,2,2] => :d,
      [:c,:d,1,-1] => :d,
      [:c,:c,2,2] => :d,
      [:c,:c,1,-1] => :d,
      [:c,:d,1,2] => :d,
      [:c,:d,2,1] => :d,
      [:c,:c,0,0] => :c,
      [:c,:c,1,1] => :d
  }
  FIXED_ACTIONS.each do |stat,act|
    se.set_fixed_action(stat, act )
  end

  LIMITED_ACTIONS = {
      states: [ [:c,:d,0,0], [:d,:c,0,0], [:d,:d,0,0] ],
      possible_actions: [
          [:c,:c,:d],
          [:c,:d,:d],
          [:d,:c,:d],
          [:d,:d,:d],
          [:c,:d,:c],
          [:d,:d,:c]
      ]
  }
  p se.fixed_actions_to_bit
  #se.set_fixed_action([:d,:d,2,2], :d )
  se.all_strategy.each do |stra|
    pp stra.to_bits
    count += 1
    break if count > 50
  end
end
