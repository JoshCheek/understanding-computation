require 'treetop'
require 'pattern/ast'
# require 'pattern/match'

class Pattern
  require 'pattern/grammar'
  Parser = PatternGrammarParser

  def self.parse(str)
    return Ast::Top.new Ast::Eos.new if str.empty?
    grammar = Parser.new
    if tree = grammar.parse(str)
      tree.to_ast
    else
      puts "\e[31m#{grammar.failure_reason}\e[0m"
      require "pry"
      binding.pry
    end
  end

  class Match

  end

  def initialize(regex)
    @source = regex.source
    @ast    = self.class.parse @source
  end

  def match(str)
    nfa    = @ast.to_nfa
    states = nfa.start_states
    # p nfa
    str.each_char do |char|
      # puts "-----"
      # p states
      # p char
      states = nfa.states_for(states, char)
      # p states
      # puts "-----"
      if (nfa.end_states & states).any?
        return Match.new
      end
    end
    return nil
  end
end
