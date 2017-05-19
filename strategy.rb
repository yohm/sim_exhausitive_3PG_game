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

