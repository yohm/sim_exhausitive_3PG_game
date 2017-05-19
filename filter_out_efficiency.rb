require 'pp'
require_relative 'graph'
require_relative 'strategy'

# Let us consider that Alice had a noise.
# The state for Alice is (CD,00) while the state for the others are (CC01).
# The state must reach (CC,00) by a deterministic way.
# Since B&C take the same action, 
#

def reaches_cc_from_1bit_noise?(str)
  a_state =  [:c,:d,0,0]
  bc_state = [:c,:c,0,1]

  a_state_history = [ State.index(a_state) ]
  loop do
    a_action = str.action( a_state )
    bc_action = str.action( bc_state )
    #pp "a_state : ", a_state
    #pp "bc_state : ", bc_state
    #pp "a_action : ", a_action
    #pp "bc_action : ", bc_action

    a_state[0] = a_state[1]
    a_state[2] = a_state[3]
    a_state[1] = a_action
    a_state[3] = (bc_action==:d ? 2 : 0)

    bc_state[0] = bc_state[1]
    bc_state[2] = bc_state[3]
    bc_state[1] = bc_action
    if a_action == :d
      if bc_action == :d
        bc_state[3] = 2
      else  # bc_action == :c
        bc_state[3] = 1
        bc_state[3] = -1 if a_state[0] == :d # consecutive defection
      end
    else  # :a_action == :c
      if bc_action == :d
        bc_state[3] = 1
        bc_state[3] = -1 if a_state[0] == :c # consecutive defection
      else  # bc_action == :c
        bc_state[3] = 0
      end
    end

    # check loop
    a_state_idx = State.index(a_state)
    break if a_state_history.include?(a_state_idx) # we reached a loop
    a_state_history << a_state_idx
  end

  #pp "final a_state: ", a_state
  #pp a_state_history.map {|i| State::ALL_STATES[i] }
  a_state == [:c,:c,0,0]
end

=begin
bits = "ccccdddcdddccccddcdddccccddcddcccccddddd"
str = Strategy.make_from_bits(bits)
p reaches_cc_from_1bit_noise?(str)
bits = "ccccdddcdddddddddddddcddddddddccdccddcdd"
str = Strategy.make_from_bits(bits)
p reaches_cc_from_1bit_noise?(str)
=end

fname = ARGV[0]
outfilename = "step2/" + File.basename(fname)
io = File.open(outfilename, 'w')
$stderr.puts "reading #{fname}, printing #{outfilename}"
File.open(fname).each do |line|
  bits = line.chomp
  str = Strategy.make_from_bits(bits)
  if reaches_cc_from_1bit_noise?(str)
    # i = reaches_cc_from_1bit_noise?(str) ? 1 : 0
    io.puts bits
  end
end
io.close

