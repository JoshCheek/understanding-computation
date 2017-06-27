require 'treetop'


Treetop.load_from_string <<~GRAMMAR
grammar PatternGrammar
  rule program
    expr:pattern {
      def to_ast
        Pattern::Top.new expr.to_ast
      end
    }
  end

  rule pattern
    nondeterministic_expr / deterministic_expr
  end

  rule nondeterministic_expr
    ( left:deterministic_expr
      '|'
      right:(nondeterministic_expr / deterministic_expr)
    ) {
      def to_ast
        Pattern::Either.new(left.to_ast, right.to_ast)
      end
    }
  end

  rule deterministic_expr
    ( first:(modified_expr / unmodified_expr)
      rest:deterministic_expr
    ) {
      def to_ast
        Pattern::Sequence.new(
          first.to_ast,
          rest.to_ast,
        )
      end
    }
    /
    modified_expr
    /
    unmodified_expr
  end

  rule modified_expr
    (expr:unmodified_expr mod:modifier) {
      def to_ast
        mod.to_ast expr.to_ast
      end
    }
  end

  rule unmodified_expr
    terminal / group
  end

  rule modifier
    mod:(zero_or_more / one_or_more / optional) {
      def to_ast(modifyee)
        mod.to_ast(modifyee)
      end
    }
  end

  rule zero_or_more
    '*' {
      def to_ast(modifyee)
        Pattern::ZeroOrMore.new(modifyee)
      end
    }
  end

  rule one_or_more
    '+' {
      def to_ast(modifyee)
        Pattern::OneOrMore.new(modifyee)
      end
    }
  end

  rule optional
    '?' {
      def to_ast(modifyee)
        Pattern::Optional.new(modifyee)
      end
    }
  end

  rule group
    '(' pattern ')' {
      def to_ast
        Pattern::Group.new pattern.to_ast
      end
    }
  end

  rule terminal
    escaped_char / char
  end

  rule escaped_char
    ( '\\\\'
      escaped:("[" / "]" / [abefnrtv(){}])
    ) {
      def to_ast
        Pattern::ExactMatch.new(
          case escaped.text_value
          when ?a then 7.chr
          when ?b then 8.chr
          when ?t then 9.chr
          when ?n then 10.chr
          when ?v then 11.chr
          when ?e then 27.chr
          when ?f then 12.chr
          when ?r then 13.chr
          when "[", "]", "(", ")", "{", "}"
            escaped.text_value
          else
            raise "wat: \#{text_value.inspect}"
          end
        )
      end
    }
  end

  rule char
    [a-zA-Z0-9] {
      def to_ast
        Pattern::ExactMatch.new(text_value)
      end
    }
  end
end
GRAMMAR


module Pattern
  extend self

  def parse(str)
    return Top.new Eos.new if str.empty?
    grammar = PatternGrammarParser.new
    tree = grammar.parse(str)
    if tree
      tree.to_ast
    else
      puts "\e[31m#{grammar.failure_reason}\e[0m"
      require "pry"
      binding.pry
    end
    # ast.the_e.empty?             # => false
    # ast.text_value               # => "e"
    # ast.elements                 # => [SyntaxNode offset=0, "e"]
    # ast.terminal?                # => false
    # ast.nonterminal?             # => true
    # to_parse = str.chars
  end

  class Top < Struct.new(:pattern)
    def inspect
      "Top.new(#{pattern.tree_inspect})"
    end
  end

  class Eos
    def ==(other)
      Eos === other
    end
    def tree_inspect
      'Eos.new'
    end
  end

  class ExactMatch < Struct.new(:char)
    def tree_inspect
      "ExactMatch.new(#{char.inspect})"
    end
  end

  class Sequence < Struct.new(:left, :right)
    def tree_inspect
      "Sequence.new(#{left.tree_inspect}, #{right.tree_inspect})"
    end
  end

  class ZeroOrMore < Struct.new(:expr)
    def tree_inspect
      "ZeroOrMore.new(#{expr.tree_inspect})"
    end
  end

  class OneOrMore < Struct.new(:expr)
    def tree_inspect
      "ZeroOrMore.new(#{expr.tree_inspect})"
    end
  end

  class Optional < Struct.new(:expr)
    def tree_inspect
      "Optional.new(#{tree_inspect})"
    end
  end

  class Either < Struct.new(:left, :right)
    def tree_inspect
      "Either.new(#{left.tree_inspect}, #{right.tree_inspect})"
    end
  end

  class Group < Struct.new(:subexpr)
    def tree_inspect
      "Group.new(#{subexpr.tree_inspect})"
    end
  end
end
