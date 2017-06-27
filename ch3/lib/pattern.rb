require 'treetop'

module Pattern
  require 'pattern/grammar'
  Parser = PatternGrammarParser

  extend self

  def parse(str)
    return Top.new Eos.new if str.empty?
    grammar = Parser.new
    if tree = grammar.parse(str)
      tree.to_ast
    else
      puts "\e[31m#{grammar.failure_reason}\e[0m"
      require "pry"
      binding.pry
    end
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
