require 'pp'
require_relative 'state_m3'
require_relative 'strategy'

class StrategyM3

  def initialize( actions )
    raise "invalid arg" unless actions.all? {|act| act == :c or act == :d }
    raise "invalid arg" unless actions.size == 512
    @actions = actions.dup
  end

  def to_bits
    @actions.join('')
  end

  def show_actions(io)
    FullStateM3::NUM_STATES.times do |i|
      act = @actions[i]
      stat = FullStateM3.make_from_id(i)
      io.print "#{act}|#{stat}\t"
      io.print "\n" if i % 10 == 9
    end
    io.print "\n"
  end

  def show_actions_latex(io)
    a_states = 0..7
    bc_states = 0..63

    io.puts <<-'EOS'
\begin{tabular}{c|cccccccc}
\hline
& \multicolumn{8}{c}{$A_{t-3}A_{t-2}A_{t-1}$} \\
$B_{t-3}B_{t-2}B_{t-1}C_{t-3}C_{t-2}C_{t-1}$ & $ccc$ & $ccd$ & $cdc$ & $cdd$ & $dcc$ & $dcd$ & $ddc$ & $ddd$ \\
\hline
EOS

    bc_states.each do |bc|
      b = bc / 8
      c = bc % 8
      next if b > c
      acts = a_states.map do |a|
        i = a * 64 + bc
        @actions[i]
      end
      bits = FullStateM3.make_from_id(bc).to_a # to make header
      header = "$#{bits[3..5].join}#{bits[6..8].join}$"
      if b != c
        header += " / $#{bits[6..8].join}#{bits[3..5].join}$"
      else
        header += "           "
      end
      io.puts header + " & " + acts.map{|x| "$#{x}$" }.join(' & ') + " \\\\"
    end

    io.puts <<-'EOS'
\hline
\end{tabular}
EOS
  end

  def self.make_from_bits( bits )
    actions = bits.each_char.map do |chr|
      chr.to_sym
    end
    self.new( actions )
  end

  def self.make_from_m2_strategy( m2_stra )
    acts = []
    FullStateM3::NUM_STATES.times do |i|
      m3_stat = FullStateM3.make_from_id(i)
      m2_stat = m3_stat.to_m2_states.last
      act = m2_stra.action( m2_stat.to_ss )
      acts << act
    end
    self.new(acts)
  end

  def modify_action( state, action )
    if state.is_a?(String)
      stat = FullStateM3.make_from_bits(state)
      @actions[stat.to_id] = action
    elsif state.is_a?(FullStateM3)
      @actions[state.to_id] = action
    else
      raise "invalid arg"
    end
  end

  def action( state_id )
    @actions[state_id]
  end

  def valid?
    @actions.all? {|a| a == :c or a == :d }
  end

  def possible_next_full_states(current_fs)
    sid = current_fs.to_id
    act_a = action(sid)
    n1 = current_fs.next_state(act_a,:c,:c)
    n2 = current_fs.next_state(act_a,:c,:d)
    n3 = current_fs.next_state(act_a,:d,:c)
    n4 = current_fs.next_state(act_a,:d,:d)
    [n1,n2,n3,n4]
  end

  def next_full_state_with_self(s)
    act_a = action(s.to_id)
    state_b = FullStateM3.new( s.b_3, s.b_2, s.b_1, s.c_3, s.c_2, s.c_1, s.a_3, s.a_2, s.a_1 )
    act_b = action(state_b.to_id)
    state_c = FullStateM3.new( s.c_3, s.c_2, s.c_1, s.b_3, s.b_2, s.b_1, s.a_3, s.a_2, s.a_1 )
    act_c = action(state_c.to_id)
    s.next_state(act_a, act_b, act_c )
  end

  def transition_graph_with_self
    g = DirectedGraph.new(512)
    512.times do |i|
      current = FullStateM3.make_from_id(i)
      next_s = next_full_state_with_self(current)
      g.add_link( i, next_s.to_id )
    end
    g
  end

  def self.node_attributes
    attr = {}
    512.times do |i|
      s = FullStateM3.make_from_id(i)
      attr[i] = {}
      attr[i][:label] = "#{i}_#{s.to_s}"
    end
    attr
  end

  def defensible?
    a1_b, a1_c = AMatrix.construct_a1_matrix(self) # construct_a1_matrix
    a_b, a_c = AMatrix.construct_a1_matrix(self)
    return false if( a_b.has_negative_diagonal? or a_c.has_negative_diagonal? )

    FullStateM3::NUM_STATES.times do |t|
      a_b.update( a1_b )
      a_c.update( a1_c )
      return false if( a_b.has_negative_diagonal? or a_c.has_negative_diagonal? )
    end
    true
  end

  def make_successful
    # noise on B&C (state 0->5)
    modify_action('ccdccdccc',:c) # (5->26)
    modify_action('ccdcccccd',:c) # (5->26)
    modify_action('cdccdcccd',:c) # (26->48)
    modify_action('cdcccdcdc',:c) # (26->48)
    # noise on B -> on B (state 4->29)
    modify_action('cddccdccd',:c) # (29->59) B
    modify_action('ddccddcdd',:c) # (59->34) B
    modify_action('cddddccdd',:c) # (59->34) A or C
    modify_action('cddcddddc',:c) # (59->34) A or C
    # noise on B -> on C (state 4->24)
    modify_action('cdcccdccc',:c) # (24->48)
    modify_action('cdccccccd',:c) # (24->48)
    modify_action('ccccdcccd',:c) # (24->48)
    modify_action('cccccdcdc',:c) # (24->48)
    # noise on B -> _ -> on B (state 25->38)
    modify_action('dcdcdccdc',:c) # (38->25)
    # noise on B -> _ -> on C (state25->35)
    modify_action('cdddcccdc',:c) # (35->48)
    modify_action('cddcdcdcc',:c) # (35->48)
  end

  class AMatrix  # class used for judging defensibility

    N = FullStateM3::NUM_STATES

    def self.construct_a1_matrix(stra)
      a_b = self.new
      a_c = self.new

      N.times do |i|
        fs = FullStateM3.make_from_id(i)
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
      @a = Array.new(N) {|i| Array.new(N,0) }
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
      temp = Array.new(N) {|i| Array.new(N,:inf) }

      N.times do |i|
        N.times do |j|
          N.times do |k|
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
  def test
    bits = "cddd" * 128
    strategy = StrategyM3.make_from_bits(bits)
    strategy.show_actions($stdout)
    pp strategy.valid?, strategy.defensible?
    raise "inconsistent bits" unless bits == strategy.to_bits

    bits = "cddcddccddcdddcdddddddccdddcccccdddddddd"
    m2_stra = Strategy.make_from_bits(bits)
    m3_stra = StrategyM3.make_from_m2_strategy(m2_stra)
  end

  test
end

