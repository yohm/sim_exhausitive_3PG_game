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

  def show_actions(io)
    State::ALL_STATES.each_with_index do |stat,idx|
      io.print "#{@strategy[stat]}|#{stat.join}\t"
      io.print "\n" if idx % 10 == 9
    end
  end

  def self.make_from_bits( bits )
    actions = bits.each_char.map do |chr|
      chr.to_sym
    end
    self.new( actions )
  end

  def action( state )
    @strategy[state]
  end

  def valid?
    @strategy.values.all? {|a| a == :c or a == :d }
  end
end

if __FILE__ == $0
  if ARGV.size == 1
    bits = ARGV[0]
    stra = Strategy.make_from_bits(bits)
    stra.show_actions($stdout)
    exit 0
  end
  bits = "ccccdddcdddccccddcdddccccddcddcccccddddd"
  strategy = Strategy.make_from_bits(bits)
  p strategy
  raise "inconsistent bits" unless bits == strategy.to_bits
  p strategy.valid?
end

