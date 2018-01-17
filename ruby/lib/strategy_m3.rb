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
      # $stderr.puts "step: #{t}/#{FullStateM3::NUM_STATES}"
      a_b.update( a1_b )
      a_c.update( a1_c )
      return false if( a_b.has_negative_diagonal? or a_c.has_negative_diagonal? )
    end
    true
  end

  def trace_state_until_cycle(s)
    trace = [s]
    loop do
      n = next_full_state_with_self(trace.last)
      if trace.include?(n)
        trace << n
        break
      else
        trace << n
      end
    end
    trace
  end

  def recovery_path_nodes(num_errors)
    if num_errors == 0
      raise "full cooperation is not a terminal state" if action(0) == :d
      return [FullStateM3.make_from_id(0)]
    else
      states = recovery_path_nodes(num_errors-1)
      return false unless states
      neighbors = states.map {|s| s.neighbor_states }.flatten.uniq {|s| s.to_id}
      traces = neighbors.map do |n|
        trace = trace_state_until_cycle(n)
        return false if trace.last.to_id != 0   # => failed to recover full cooperation
        trace
      end
      (neighbors + traces.flatten).uniq {|s| s.to_id} # nodes which is necessary to recover from errors
    end
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
  require 'minitest/autorun'

  class StrategyM3Test < Minitest::Test

    def test_allD
      bits = "d"*512
      stra = StrategyM3.make_from_bits(bits)
      assert_equal bits, stra.to_bits
      assert_equal :d, stra.action(0)
      assert_equal :d, stra.action(511)
      assert_equal true, stra.valid?

      s = FullStateM3.new(:d,:c,:c,:c,:c,:d,:d,:d,:c)
      nexts = stra.possible_next_full_states(s).map(&:to_s)
      expected = ['ccd-cdc-dcc', 'ccd-cdc-dcd', 'ccd-cdd-dcc', 'ccd-cdd-dcd']
      assert_equal expected, nexts

      next_state = stra.next_full_state_with_self(s)
      assert_equal 'ccd-cdd-dcd', next_state.to_s

      # assert_equal true, stra.defensible?  # it takes too long time
    end

    def test_allC
      bits = "c"*512
      stra = StrategyM3.make_from_bits(bits)
      assert_equal bits, stra.to_bits
      assert_equal :c, stra.action(0)
      assert_equal :c, stra.action(511)
      assert_equal true, stra.valid?

      s = FullStateM3.new(:d,:c,:c,:c,:c,:d,:d,:d,:c)
      nexts = stra.possible_next_full_states(s).map(&:to_s)
      expected = ['ccc-cdc-dcc', 'ccc-cdc-dcd', 'ccc-cdd-dcc', 'ccc-cdd-dcd']
      assert_equal expected, nexts

      next_state = stra.next_full_state_with_self(s)
      assert_equal 'ccc-cdc-dcc', next_state.to_s

      assert_equal false, stra.defensible?
    end

    def test_make_from_m2_strategy
      bits = "cddcdddcddcccdcddddddcccdddcccccddcddddd"
      m2_stra = Strategy.make_from_bits(bits)
      m3_stra = StrategyM3.make_from_m2_strategy(m2_stra)

      assert_equal :c, m3_stra.action(0)
      assert_equal :d, m3_stra.action(511)

      m3_stra.modify_action('ddddddddd', :c)
      assert_equal :c, m3_stra.action(511)
    end

    def test_SS
      # the most generous successful strategy
      bits = "cdcdcdcdddcdddddcccdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddccddccddcccdcccddcdddcddddddddddccddccddcccdcccddcdddcdddddddddddccddccdcccdccddcccccdccddccddccdccddccdccddccddcdcccdccddccddccccddccddcccdcdcddcddccddddddddcdcccdccddcdcdcdcddcdcdcddddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddccddccddcccdcccddccddcddddddddddccddccddcccdcccddcdddcdddddddddddccddccdccddccddcdcccdccddccddccdccddccdccddccddcdcccdccddccddccccddccddcdcdcdcddcdddcddddddddddccddccddcdcdcdcddcdddcdddddddddd"
      stra = StrategyM3.make_from_bits(bits)

      assert_equal :c, stra.action(0)
      assert_equal :d, stra.action(511)
    end

    def test_recovery_allC
      bits = "c"*512
      stra = StrategyM3.make_from_bits(bits)

      assert_equal ['ccc-ccc-ccc'], stra.recovery_path_nodes(0).map(&:to_s)

      path = stra.recovery_path_nodes(1)
      path_a = ['ccd-ccc-ccc','cdc-ccc-ccc','dcc-ccc-ccc','ccc-ccc-ccc']
      path_b = swap_players(path_a,0,1)
      path_c = swap_players(path_a,0,2)
      assert_equal (path_a+path_b+path_c).uniq.sort, path.map(&:to_s).sort

      path = stra.recovery_path_nodes(2)
      path_ab = ['ccd-ccd-ccc','cdc-cdc-ccc','dcc-dcc-ccc','ccc-ccc-ccc']
      path_ac = swap_players(path_ab,1,2)
      path_bc = swap_players(path_ab,0,2)

      path_a_a = ['ccd-ccc-ccc','cdd-ccc-ccc','ddc-ccc-ccc','dcc-ccc-ccc','ccc-ccc-ccc']
      path_a_b = ['ccd-ccc-ccc','cdc-ccd-ccc','dcc-cdc-ccc','ccc-dcc-ccc','ccc-ccc-ccc']
      path_a_c = swap_players(path_a_b,1,2)
      path_b_a = swap_players(path_a_b,0,1)
      path_b_b = swap_players(path_a_a,0,1)
      path_b_c = swap_players(path_b_a,0,2)
      path_c_a = swap_players(path_a_c,0,2)
      path_c_b = swap_players(path_c_a,0,1)
      path_c_c = swap_players(path_a_a,0,2)

      path_a__a = ['ccd-ccc-ccc','cdc-ccc-ccc','dcd-ccc-ccc','cdc-ccc-ccc','dcc-ccc-ccc','ccc-ccc-ccc']
      path_a__b = ['ccd-ccc-ccc','cdc-ccc-ccc','dcc-ccd-ccc','ccc-cdc-ccc','ccc-dcc-ccc','ccc-ccc-ccc']
      path_a__c = swap_players(path_a__b,1,2)
      path_b__a = swap_players(path_a__b,0,1)
      path_b__b = swap_players(path_a__a,0,1)
      path_b__c = swap_players(path_b__a,0,2)
      path_c__a = swap_players(path_b__a,1,2)
      path_c__b = swap_players(path_c__a,0,1)
      path_c__c = swap_players(path_a__a,0,2)

      all = path_ab+path_ac+path_bc+path_a_a+path_a_b+path_a_c+path_b_a+path_b_b+path_b_c+
          path_c_a+path_c_b+path_c_c+path_a__a+path_a__b+path_a__c+path_b__a+path_b__b+path_b__c+path_c__a+path_c__b+path_c__c
      assert_equal all.uniq.sort, path.map(&:to_s).sort
    end

    def test_recovery_PS2
      # most generous version of PS2 extended to m=3
      bits = "cdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddccddccddcccdcccddcdddcddddddddddccddccddcccdcccddcdddcdddddddddddccddccdccddccddcdcccdccddccddccdccddccdccddccddcdcccdccddccddccccddccddcdcdcdcddcdddcddddddddddccddccddcdcdcdcddcdddcddddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddccddccddcccdcccddcdddcddddddddddccddccddcccdcccddcdddcdddddddddddccddccdccddccddcdcccdccddccddccdccddccdccddccddcdcccdccddccddccccddccddcdcdcdcddcdddcddddddddddccddccddcdcdcdcddcdddcdddddddddd"
      stra = StrategyM3.make_from_bits(bits)

      assert_equal ['ccc-ccc-ccc'], stra.recovery_path_nodes(0).map(&:to_s)

      path = stra.recovery_path_nodes(1)
      path_a = ['ccd-ccc-ccc','cdc-ccd-ccd','dcc-cdc-cdc','ccc-dcc-dcc','ccc-ccc-ccc']
      path_b = swap_players(path_a,0,1)
      path_c = swap_players(path_a,0,2)
      assert_equal (path_a+path_b+path_c).uniq.sort, path.map(&:to_s).sort

      assert_equal false, stra.recovery_path_nodes(2)
    end

    def test_recovery_SS
      # most generous successful m=3 strategy
      bits = "cdcdcdcdddcdddddcccdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddccddccddcccdcccddcdddcddddddddddccddccddcccdcccddcdddcdddddddddddccddccdcccdccddcccccdccddccddccdccddccdccddccddcdcccdccddccddccccddccddcccdcdcddcddccddddddddcdcccdccddcdcdcdcddcdcdcddddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddcdcdcdcdddddddddccddccddcccdcccddccddcddddddddddccddccddcccdcccddcdddcdddddddddddccddccdccddccddcdcccdccddccddccdccddccdccddccddcdcccdccddccddccccddccddcdcdcdcddcdddcddddddddddccddccddcdcdcdcddcdddcdddddddddd"
      stra = StrategyM3.make_from_bits(bits)

      assert_equal ['ccc-ccc-ccc'], stra.recovery_path_nodes(0).map(&:to_s)
      path = stra.recovery_path_nodes(1)
      path_a = ['ccd-ccc-ccc','cdc-ccd-ccd','dcc-cdc-cdc','ccc-dcc-dcc','ccc-ccc-ccc']
      path_b = swap_players(path_a,0,1)
      path_c = swap_players(path_a,0,2)
      assert_equal (path_a+path_b+path_c).uniq.sort, path.map(&:to_s).sort

      path = stra.recovery_path_nodes(2)
      path_bc = ['ccc-ccd-ccd','ccd-cdc-cdc','cdd-dcc-dcc','ddc-ccd-ccd','dcc-cdc-cdc','ccc-dcc-dcc','ccc-ccc-ccc']
      path_ab = swap_players(path_bc,0,2)
      path_ac = swap_players(path_ab,1,2)

      path_b_b = ['ccc-ccd-ccc','ccd-cdd-ccd','cdd-ddc-cdd','ddc-dcc-ddc','dcc-ccc-dcc','ccc-ccc-ccc']
      path_b_c = ['ccc-ccd-ccc','ccd-cdc-ccc','cdd-dcc-ccc','ddc-ccd-ccd','dcc-cdc-cdc','ccc-dcc-dcc','ccc-ccc-ccc']
      path_a_a = swap_players(path_b_b,0,1)
      path_a_b = swap_players(swap_players(path_b_c,0,1),1,2)
      path_a_c = swap_players(path_a_b,1,2)
      path_b_a = swap_players(path_a_b,0,1)
      #path_b_b = swap_players(path_a_a,0,1)
      #path_b_c = swap_players(path_b_a,0,2)
      path_c_a = swap_players(path_a_c,0,2)
      path_c_b = swap_players(path_c_a,0,1)
      path_c_c = swap_players(path_a_a,0,2)

      path_b__b = ['ccc-ccd-ccc','ccd-cdc-ccd','cdc-dcd-cdc','dcd-cdc-dcd','cdc-dcc-cdc','dcc-ccc-dcc','ccc-ccc-ccc']
      path_b__c = ['ccc-ccd-ccc','ccd-cdc-ccd','cdc-dcc-cdd','dcd-ccd-ddc','cdc-cdc-dcc','dcc-dcc-ccc','ccc-ccc-ccc']
      path_a__a = swap_players(path_b__b,0,1)
      path_a__b = swap_players(swap_players(path_b__c,1,2), 0,2)
      path_a__c = swap_players(path_a__b,1,2)
      path_b__a = swap_players(path_a__b,0,1)
      #path_b__b = swap_players(path_a__a,0,1)
      #path_b__c = swap_players(path_b__a,0,2)
      path_c__a = swap_players(path_b__a,1,2)
      path_c__b = swap_players(path_c__a,0,1)
      path_c__c = swap_players(path_a__a,0,2)

      path_b___b = ['ccc-ccd-ccc','ccd-cdc-ccd','cdc-dcc-cdc','dcc-ccd-dcc','ccd-cdc-ccd','cdc-dcc-cdc','dcc-ccc-dcc','ccc-ccc-ccc']
      path_a___a = swap_players(path_b___b,0,1)
      path_c___c = swap_players(path_a___a,0,2)
      path_b___c = ['ccc-ccd-ccc','ccd-cdc-ccd','cdc-dcc-cdc','dcc-ccc-dcd','ccd-ccd-cdc','cdc-cdc-dcc','dcc-dcc-ccc','ccc-ccc-ccc']
      path_b___a = swap_players(path_b___c,0,2)
      path_a___c = swap_players(path_b___c,0,1)
      path_a___b = swap_players(path_a___c,1,2)
      path_c___a = swap_players(path_b___a,1,2)
      path_c___b = swap_players(path_c___a,0,1)

      all = (path_a+path_b+path_c+
          path_ab+path_ac+path_bc+path_a_a+path_a_b+path_a_c+path_b_a+path_b_b+path_b_c+
          path_c_a+path_c_b+path_c_c+path_a__a+path_a__b+path_a__c+path_b__a+path_b__b+path_b__c+path_c__a+path_c__b+path_c__c+
          path_a___a+path_a___b+path_a___c+path_b___a+path_b___b+path_b___c+path_c___a+path_c___b+path_c___c).uniq
      assert_equal [], (path.map(&:to_s)-all).sort
      assert_equal [], (all-path.map(&:to_s)).sort
      assert_equal all.uniq.sort, path.map(&:to_s).uniq.sort
    end

    def swap_players(states, p1 = 0, p2 = 1)
      states.map {|state|
        splitted = state.split('-')
        splitted[p1], splitted[p2] = splitted[p2], splitted[p1]
        splitted.join('-')
      }
    end

  end

end

