require 'pp'
require_relative 'state'

class FullStateM3

  NUM_STATES = 512

  def self.make_from_id( id )
    raise "invalid arg: #{id}" if id < 0 or id >= NUM_STATES
    c_1 = ( ((id >> 0) & 1) == 1 ) ? :d : :c
    c_2 = ( ((id >> 1) & 1) == 1 ) ? :d : :c
    c_3 = ( ((id >> 2) & 1) == 1 ) ? :d : :c
    b_1 = ( ((id >> 3) & 1) == 1 ) ? :d : :c
    b_2 = ( ((id >> 4) & 1) == 1 ) ? :d : :c
    b_3 = ( ((id >> 5) & 1) == 1 ) ? :d : :c
    a_1 = ( ((id >> 6) & 1) == 1 ) ? :d : :c
    a_2 = ( ((id >> 7) & 1) == 1 ) ? :d : :c
    a_3 = ( ((id >> 8) & 1) == 1 ) ? :d : :c
    self.new(a_3,a_2,a_1, b_3,b_2,b_1, c_3,c_2,c_1)
  end

  def self.make_from_bits( bits )
    raise "invalid arg" unless bits.is_a?(String) and bits.length == 9 and bits.each_char.all? {|b| b=='c' or b=='d'}

    args = bits.each_char.map(&:to_sym)
    self.new(*args)
  end

  attr_reader :a_3,:a_2,:a_1,:b_3,:b_2,:b_1,:c_3,:c_2,:c_1

  def initialize(a_3,a_2,a_1,b_3,b_2,b_1,c_3,c_2,c_1)
    @a_3 = a_3
    @a_2 = a_2
    @a_1 = a_1
    @b_3 = b_3
    @b_2 = b_2
    @b_1 = b_1
    @c_3 = c_3
    @c_2 = c_2
    @c_1 = c_1
    unless to_a.all? {|a| a == :d or a == :c }
      raise "invalid state"
    end
  end

  def to_a
    [@a_3,@a_2,@a_1,@b_3,@b_2,@b_1,@c_3,@c_2,@c_1]
  end

  def to_id
    nums = to_a.each_with_index.map do |act,idx|
      act == :d ? 2**(8-idx) : 0
    end
    nums.inject(:+)
  end

  def ==(other)
    self.to_id == other.to_id
  end

  def to_m2_states
    fs1 = FullState.new(@a_3,@a_2,@b_3,@b_2,@c_3,@c_2)
    fs2 = FullState.new(@a_2,@a_1,@b_2,@b_1,@c_2,@c_1)
    [fs1,fs2]
  end

  def next_state(act_a,act_b,act_c)
    self.class.new(@a_2,@a_1,act_a,@b_2,@b_1,act_b,@c_2,@c_1,act_c)
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

  def to_s
    a = to_a
    a[0..2].join('') + '-' + a[3..5].join('') + '-' + a[6..8].join('')
  end
end

if __FILE__ == $0
  require 'minitest/autorun'

  class StateM3Test < Minitest::Test

    def test_alld
      fs = FullStateM3.make_from_id(511)
      assert_equal [:d,:d,:d,:d,:d,:d,:d,:d,:d], fs.to_a
      assert_equal 'ddd-ddd-ddd', fs.to_s
      assert_equal 511, fs.to_id
      assert_equal 0, fs.relative_payoff_against(:C)
      assert_equal 0, fs.relative_payoff_against(:B)
    end

    def test_allc
      fs = FullStateM3.make_from_id(0)
      assert_equal [:c,:c,:c,:c,:c,:c,:c,:c,:c], fs.to_a
      assert_equal 'ccc-ccc-ccc', fs.to_s
      assert_equal 0, fs.to_id
      assert_equal 0, fs.relative_payoff_against(:B)
      assert_equal 0, fs.relative_payoff_against(:C)
    end

    def test_state273
      fs = FullStateM3.make_from_id(273)
      assert_equal [:d, :c, :c, :c, :d, :c, :c, :c, :d], fs.to_a
      assert_equal 'dcc-cdc-ccd', fs.to_s
      assert_equal 273, fs.to_id
      assert_equal 0, fs.relative_payoff_against(:B)
      assert_equal -1, fs.relative_payoff_against(:C)
      assert_equal ['dccdcc','ccdccd'], fs.to_m2_states.map(&:to_s)
      assert_equal 'ccc-dcd-cdd', fs.next_state(:c,:d,:d).to_s
    end

    def test_equality
      fs1 = FullStateM3.make_from_id(273)
      fs2 = FullStateM3.new(:d,:c,:c,:c,:d,:c,:c,:c,:d)
      assert_equal true, fs1==fs2
    end
  end
end

