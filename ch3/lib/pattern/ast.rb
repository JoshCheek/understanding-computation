require 'pattern/nfa'
require 'set'

class Pattern
  module Ast
    class Top < Struct.new(:pattern)
      def inspect
        "Top.new(#{pattern.tree_inspect})"
      end
      def to_nfa
        state       = 1
        stategen    = lambda { state += 1 }
        start_state = stategen.call
        end_state   = stategen.call
        nfas        = pattern.nfas_for(start_state, end_state, stategen)
        transitions = Set.new(nfas)
        Nfa.new(
          Set[start_state],
          Set[end_state],
          transitions,
        )
      end
    end

    class Eos
      def ==(other)
        Eos === other
      end

      def tree_inspect
        'Eos.new'
      end

      def nfas_for(ss, es, stategen)
        [[ss, nil, es]]
      end
    end

    class ExactMatch < Struct.new(:char)
      def tree_inspect
        "ExactMatch.new(#{char.inspect})"
      end
      def nfas_for(ss, es, stategen)
        [[ss, char, es]]
      end
    end

    class Sequence < Struct.new(:left, :right)
      def tree_inspect
        "Sequence.new(#{left.tree_inspect}, #{right.tree_inspect})"
      end
      def nfas_for(ss, es, stategen)
        is = stategen.call
        left_nfas = left.nfas_for(ss, is, stategen)
        right_nfs = right.nfas_for(is, es, stategen)
        left_nfas + right_nfs
      end
    end

    class ZeroOrMore < Struct.new(:expr)
      def tree_inspect
        "ZeroOrMore.new(#{expr.tree_inspect})"
      end

      def nfas_for(ss, es, stategen)
        [[ss, nil, es],
         *expr.nfas_for(ss, ss, stategen),
        ]
      end
    end

    class OneOrMore < Struct.new(:expr)
      def tree_inspect
        "ZeroOrMore.new(#{expr.tree_inspect})"
      end

      def nfas_for(ss, es, stategen)
        is = stategen.call
        [ *expr.nfas_for(ss, is, stategen),
          *ZeroOrMore.new(expr).nfas_for(is, es, stategen)
        ]
      end
    end

    class Optional < Struct.new(:expr)
      def tree_inspect
        "Optional.new(#{tree_inspect})"
      end
      def nfas_for(ss, es, stategen)
        [[ss, nil, es],
         *expr.nfas_for(ss, es, stategen),
        ]
      end
    end

    class Either < Struct.new(:left, :right)
      def tree_inspect
        "Either.new(#{left.tree_inspect}, #{right.tree_inspect})"
      end
      def nfas_for(ss, es, stategen)
        [ *left.nfas_for(ss, es, stategen),
          *right.nfas_for(ss, es, stategen),
        ]
      end
    end

    class Group < Struct.new(:subexpr)
      def tree_inspect
        "Group.new(#{subexpr.tree_inspect})"
      end
      def nfas_for(ss, es, stategen)
        subexpr.nfas_for(ss, es, stategen)
      end
    end
  end
end
