require_relative 'strategy'
require 'pp'

class StrategyEnumerator

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

  LIMITED_ACTIONS1 = {
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

  LIMITED_ACTIONS2 = {
      states: [
          [:c, :c, 1, 2],
          [:c, :c, 2, 1],
          [:d, :c, 1, -1],
          [:d, :c, 1, 2],
          [:d, :c, 2, 1],
          [:d, :c, 2, 2]
      ],
      possible_actions: [
          [:d, :c, :c, :c, :c, :c],
          [:c, :d, :c, :c, :c, :c],
          [:d, :d, :c, :c, :c, :c],
          [:d, :c, :d, :c, :c, :c],
          [:c, :d, :d, :c, :c, :c],
          [:d, :d, :d, :c, :c, :c],
          [:d, :c, :c, :d, :c, :c],
          [:c, :d, :c, :d, :c, :c],
          [:d, :d, :c, :d, :c, :c],
          [:d, :c, :d, :d, :c, :c],
          [:c, :d, :d, :d, :c, :c],
          [:d, :d, :d, :d, :c, :c],
          [:d, :c, :c, :c, :d, :c],
          [:c, :d, :c, :c, :d, :c],
          [:d, :d, :c, :c, :d, :c],
          [:d, :c, :d, :c, :d, :c],
          [:c, :d, :d, :c, :d, :c],
          [:d, :d, :d, :c, :d, :c],
          [:d, :c, :c, :d, :d, :c],
          [:c, :d, :c, :d, :d, :c],
          [:d, :d, :c, :d, :d, :c],
          [:d, :c, :d, :d, :d, :c],
          [:c, :d, :d, :d, :d, :c],
          [:d, :d, :d, :d, :d, :c],
          [:d, :c, :c, :c, :c, :d],
          [:c, :d, :c, :c, :c, :d],
          [:d, :d, :c, :c, :c, :d],
          [:d, :c, :d, :c, :c, :d],
          [:c, :d, :d, :c, :c, :d],
          [:d, :d, :d, :c, :c, :d],
          [:d, :c, :c, :d, :c, :d],
          [:c, :d, :c, :d, :c, :d],
          [:d, :d, :c, :d, :c, :d],
          [:d, :c, :d, :d, :c, :d],
          [:c, :d, :d, :d, :c, :d],
          [:d, :d, :d, :d, :c, :d],
          [:d, :c, :c, :c, :d, :d],
          [:c, :d, :c, :c, :d, :d],
          [:d, :d, :c, :c, :d, :d],
          [:d, :c, :d, :c, :d, :d],
          [:c, :d, :d, :c, :d, :d],
          [:d, :d, :d, :c, :d, :d],
          [:d, :c, :c, :d, :d, :d],
          [:c, :d, :c, :d, :d, :d],
          [:d, :d, :c, :d, :d, :d],
          [:d, :c, :d, :d, :d, :d],
          [:c, :d, :d, :d, :d, :d],
          [:d, :d, :d, :d, :d, :d]
      ]
  }

  def initialize
    n = State::ALL_STATES.size
  end

  def fixed_actions_to_bit
    State::ALL_STATES.map do |stat|
      if FIXED_ACTIONS[stat]
        FIXED_ACTIONS[stat]
      elsif LIMITED_ACTIONS1[:states].include?(stat)
        '*'
      elsif LIMITED_ACTIONS2[:states].include?(stat)
        '#'
      else
        '-'
      end
    end.join
  end

  def all_strategy
    actions = Array.new( State::ALL_STATES.size, nil )

    e = Enumerator.new do |y|
      # set fixed actions
      FIXED_ACTIONS.each do |stat, act|
        idx = State.index(stat)
        actions[idx] = act
      end

      # iterate on limited actions
      i1,i2,i3 = LIMITED_ACTIONS1[:states].map {|s| State.index(s)}
      LIMITED_ACTIONS1[:possible_actions].reverse.each do |a1,a2,a3|
        actions[i1] = a1
        actions[i2] = a2
        actions[i3] = a3

        i4,i5,i6,i7,i8,i9 = LIMITED_ACTIONS2[:states].map {|s| State.index(s)}
        LIMITED_ACTIONS2[:possible_actions].reverse.each do |a4,a5,a6,a7,a8,a9|
          actions[i4] = a4
          actions[i5] = a5
          actions[i6] = a6
          actions[i7] = a7
          actions[i8] = a8
          actions[i9] = a9

          unfixed_states = State::ALL_STATES - FIXED_ACTIONS.keys - LIMITED_ACTIONS1[:states] - LIMITED_ACTIONS2[:states]
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
          iterate_for.call(0)
        end
      end
    end
    e
  end
end

if __FILE__ == $0
  #p State::ALL_STATES
  #p State::ALL_STATES.size
  #p s = Strategy.new( [:c,:d]*20 )
  #p s.valid?
  require 'fileutils'
  FileUtils.mkdir_p("step1")
  se = StrategyEnumerator.new
  $stderr.puts se.fixed_actions_to_bit
  count = 0
  total_num_strategies = (2**28)*9/16
  NUM_NODES = 384
  num_strategy_per_node = (total_num_strategies.to_f / NUM_NODES).ceil
  fname = sprintf("step1/bits%03d.txt", count / num_strategy_per_node )
  io = File.open(fname,'w')
  se.all_strategy.each do |stra|
    io.puts stra.to_bits
    count += 1
    if count % 1_000_000 == 0
      $stderr.puts "count: #{count} / #{total_num_strategies}"
      #break
    end
    if count % num_strategy_per_node == 0
      io.close
      fname = sprintf("step1/bits%03d.txt", count / num_strategy_per_node )
      io = File.open(fname,'w')
    end
  end
  io.close
end