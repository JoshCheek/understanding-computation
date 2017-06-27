class Pattern
  class Nfa < Struct.new(:start_states, :end_states, :transitions)
    # def initialize(start_states, end_states, transitions)
    #   self.transitions  = transitions
    #   self.start_states = start_states + states_for(start_states, nil)
    #   self.end_states   = end_states
    # end
    def states_for(initial_states, input)
      states = follow_once(initial_states, input)
      loop do
        next_states = follow_once states, nil
        break if next_states.subset? states
        states = states + next_states
      end
      states
    end

    private

    def follow_once(initial_states, input)
      potentially_relevant = transitions.select do |from, action, to|
        action == input && initial_states.include?(from)
      end
      Set.new potentially_relevant.map { |*, to| to }
    end
  end
end
