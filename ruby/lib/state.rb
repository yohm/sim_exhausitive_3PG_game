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

class FullState

  def self.make_from_id( id )
    raise "invalid arg: #{id}" if id < 0 or id > 63
    c_1 = ( ((id >> 0) & 1) == 1 ) ? :d : :c
    c_2 = ( ((id >> 1) & 1) == 1 ) ? :d : :c
    b_1 = ( ((id >> 2) & 1) == 1 ) ? :d : :c
    b_2 = ( ((id >> 3) & 1) == 1 ) ? :d : :c
    a_1 = ( ((id >> 4) & 1) == 1 ) ? :d : :c
    a_2 = ( ((id >> 5) & 1) == 1 ) ? :d : :c
    self.new(a_2, a_1, b_2, b_1, c_2, c_1)
  end

  attr_reader :a_2,:a_1,:b_2,:b_1,:c_2,:c_1

  def initialize(a_2,a_1,b_2,b_1,c_2,c_1)
    @a_2 = a_2
    @a_1 = a_1
    @b_2 = b_2
    @b_1 = b_1
    @c_2 = c_2
    @c_1 = c_1
    unless [@a_2,@a_1,@b_2,@b_1,@c_2,@c_1].all? {|a| a == :d or a == :c }
      raise "invalid state"
    end
  end

  def to_a
    [@a_2,@a_1,@b_2,@b_1,@c_2,@c_1]
  end

  def to_s
    to_a.join('')
  end

  def to_id
    id = 0
    id += 32 if @a_2 == :d
    id += 16 if @a_1 == :d
    id += 8  if @b_2 == :d
    id += 4  if @b_1 == :d
    id += 2  if @c_2 == :d
    id += 1  if @c_1 == :d
    id
  end

  def to_ss
    ss = []
    ss[0] = @a_2
    ss[1] = @a_1

    if @b_2 == :d and @c_2 == :d
      bc_2 = 2
    elsif @b_2 == :d or @c_2 == :d
      bc_2 = 1
    else
      bc_2 = 0
    end

    if @b_1 == :d and @c_1 == :d
      bc_1 = 2
    elsif @b_1 == :d or @c_1 == :d
      if bc_2 == 1 and @b_2 == @b_1
        bc_1 = -1
      else
        bc_1 = 1
      end
    else
      bc_1 = 0
    end
    ss[2] = bc_2
    ss[3] = bc_1
    ss
  end

  def next_state(act_a,act_b,act_c)
    self.class.new(@a_1,act_a,@b_1,act_b,@c_1,act_c)
  end

  def relative_payoff_against(other)
    if other == :B
      act = @b_1
    elsif other == :C
      act = @c_1
    else
      raise "must not happen"
    end

    if @a_1 == act
      return 0
    elsif @a_1 == :c and act == :d
      return -1
    elsif @a_1 == :d and act == :c
      return 1
    else
      raise "must not happen"
    end
  end

end

if __FILE__ == $0
  require 'minitest/autorun'

  class StateTest < Minitest::Test

    def test_alld
      fs = FullState.make_from_id(63)
      assert_equal [:d,:d,:d,:d,:d,:d], fs.to_a
      assert_equal [:d,:d,2,2], fs.to_ss
      assert_equal 0, fs.relative_payoff_against(:B)
      assert_equal 0, fs.relative_payoff_against(:C)
    end

    def test_allc
      fs = FullState.make_from_id(0)
      assert_equal [:c,:c,:c,:c,:c,:c], fs.to_a
      assert_equal [:c,:c,0,0], fs.to_ss
      assert_equal 0, fs.relative_payoff_against(:B)
      assert_equal 0, fs.relative_payoff_against(:C)
    end

    def test_state43
      fs = FullState.make_from_id(43)
      assert_equal [:d, :c, :d, :c, :d, :d], fs.to_a
      assert_equal [:d,:c,2,1], fs.to_ss
      assert_equal 0, fs.relative_payoff_against(:B)
      assert_equal -1, fs.relative_payoff_against(:C)
      assert_equal [:c,:c,:c,:d,:d,:d], fs.next_state(:c,:d,:d).to_a
    end

    def test_state44
      fs = FullState.make_from_id(44)
      assert_equal [:d, :c, :d, :d, :c, :c], fs.to_a
      assert_equal [:d,:c,1,-1], fs.to_ss
      assert_equal -1, fs.relative_payoff_against(:B)
      assert_equal 0, fs.relative_payoff_against(:C)
      assert_equal [:c,:d,:d,:d,:c,:d], fs.next_state(:d,:d,:d).to_a
    end
  end
end

