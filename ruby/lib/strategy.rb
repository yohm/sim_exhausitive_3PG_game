require 'pp'
require_relative 'state'
require_relative 'graph'

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

  def show_actions_latex(io)
    num_col = 4
    num_row = State::ALL_STATES.size / num_col
    num_row.times do |row|
      num_col.times do |col|
        idx = row + col * num_row
        stat = State::ALL_STATES[idx]
        s = stat.map do |c|
          if c == -1
            '\bar{1}'
          elsif c.is_a?(Integer)
            c.to_s
          else
            c.capitalize
          end
        end
        s.insert(2,',')
        io.print "$(#{s.join})$ & $#{@strategy[stat].capitalize}$ "
        io.print "& " unless col == num_col - 1
      end
      io.puts "\\\\"
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

  def possible_next_full_states(current_fs)
    ss = current_fs.to_ss
    act_a = action(ss)
    n1 = current_fs.next_state(act_a,:c,:c)
    n2 = current_fs.next_state(act_a,:c,:d)
    n3 = current_fs.next_state(act_a,:d,:c)
    n4 = current_fs.next_state(act_a,:d,:d)
    [n1,n2,n3,n4]
  end

  def next_full_state_with_self(fs)
    act_a = action( fs.to_ss )
    fs_b = FullState.new( fs.b_2, fs.b_1, fs.c_2, fs.c_1, fs.a_2, fs.a_1 )
    act_b = action( fs_b.to_ss )
    fs_c = FullState.new( fs.c_2, fs.c_1, fs.b_2, fs.b_1, fs.a_2, fs.a_1 )
    act_c = action( fs_c.to_ss )
    next_fs = fs.next_state( act_a, act_b, act_c )
    next_fs
  end

  def transition_graph
    g = DirectedGraph.new(64)
    64.times do |i|
      fs = FullState.make_from_id(i)
      next_fss = possible_next_full_states(fs)
      next_fss.each do |next_fs|
        g.add_link(i,next_fs.to_id)
      end
    end
    g
  end

  def transition_graph_with_self
    g = DirectedGraph.new(64)
    64.times do |i|
      fs = FullState.make_from_id(i)
      next_fs = next_full_state_with_self(fs)
      g.add_link( i, next_fs.to_id )
    end
    g
  end

  def defensible?
    a1_b, a1_c = AMatrix.construct_a1_matrix(self) # construct_a1_matrix
    a_b, a_c = AMatrix.construct_a1_matrix(self)
    return false if( a_b.has_negative_diagonal? or a_c.has_negative_diagonal? )

    63.times do |t|
      a_b.update( a1_b )
      a_c.update( a1_c )
      return false if( a_b.has_negative_diagonal? or a_c.has_negative_diagonal? )
    end
    true
  end

  class AMatrix  # class used for judging defensibility

    N=64

    def self.construct_a1_matrix(stra)
      a_b = self.new
      a_c = self.new

      N.times do |i|
        fs = FullState.make_from_id(i)
        N.times do |j|
          a_b.a[i][j] = :inf
          a_c.a[i][j] = :inf
        end
        next_fss = stra.possible_next_full_states(fs)
        next_fss.each do |ns|
          j = ns.to_id
          a_b.a[i][j] = ns.relative_payoff_against(:B)
          a_c.a[i][j] = ns.relative_payoff_against(:C)
        end
      end
      [a_b, a_c]
    end

    attr_reader :a

    def initialize
      @a = Array.new(64) {|i| Array.new(64,0) }
    end

    def inspect
      sio = StringIO.new
      @a.size.times do |i|
        @a[i].size.times do |j|
          if @a[i][j] == :inf
            sio.print(" ##,")
          else
            sio.printf("%3d,", @a[i][j])
          end
        end
        sio.print "\n"
      end
      sio.string
    end

    def has_negative_diagonal?
      @a.size.times do |i|
        if @a[i][i] != :inf and @a[i][i] < 0
          return true
        end
      end
      false
    end

    def update( a1 )
      temp = Array.new(64) {|i| Array.new(64,:inf) }

      @a.size.times do |i|
        @a.size.times do |j|
          @a.size.times do |k|
            x = @a[i][k]
            y = a1.a[k][j]
            next if x == :inf or y == :inf
            temp[i][j] = x+y if temp[i][j] == :inf or x+y < temp[i][j]
          end
        end
      end
      @a = temp
    end
  end

end

if __FILE__ == $0
  if ARGV.size == 1
    bits = ARGV[0]
    stra = Strategy.make_from_bits(bits)
    stra.show_actions($stdout)
    #stra.transition_graph_with_self.to_dot($stdout)
    #stra.show_actions_latex($stdout)
    #a1_b, a1_c = Strategy::AMatrix.construct_a1_matrix(stra)
    #pp a1_b
    #pp a1_b.has_negative_diagonal?
    #a1_b.update(a1_b)
    #pp a1_b
    #pp "def: #{stra.defensible?}"
    exit 0
  end
  bits = "ccccdddcdddccccddcdddccccddcddcccccddddd"
  strategy = Strategy.make_from_bits(bits)
  p strategy
  raise "inconsistent bits" unless bits == strategy.to_bits
  p strategy.valid?
end

