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

  def self.all
    e = Enumerator.new do |y|
      A_STATES.each do |a|
        BC_STATES.each do |b|
          y << a+b
        end
      end
    end
    e
  end

  def self.valid?
    A_STATES.include?( @state[0..1] ) and BC_STATES.include?( @state[2..3] )
  end

end

class Strategy

  def initialize( actions )
    @strategy = Hash[ State.all.zip( actions ) ]
  end

  def to_bits
    State.all.map do |stat|
      @strategy[stat] == :c ? 'c' : 'd'
    end.join
  end

  def valid?
    @strategy.values.all? {|a| a == :c or a == :d }
  end
end

class StrategySpace

  def initialize
    n = State.all.to_a.size
    possible_actions = [[:c,:d]]*n
    @space = Hash[ State.all.zip( possible_actions ) ]
  end

  def size
    action_nums = @space.map do |_,actions|
      actions.size
    end
    action_nums.inject(1, :*)
  end

  def all_strategy
    states = State.all.to_a
    e = Enumerator.new do |y|
      actions = Array.new( states.size, nil )
      iterate_for = lambda do |stat_idx|
        stat = states[stat_idx]
        @space[stat].each do |act|
          actions[stat_idx] = act
          if stat_idx < states.size-1
            iterate_for.call(stat_idx+1)
          else
            pp stat_idx
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
  State.all.each {|s| p s}
  p State.all.to_a.size
  p s = Strategy.new( [:c,:d]*20 )
  p s.valid?
  p ss = StrategySpace.new
  p ss.size
  count = 0
  ss.all_strategy.each do |stra|
    pp stra.to_bits
    count += 1
    break if count > 100
  end
end
