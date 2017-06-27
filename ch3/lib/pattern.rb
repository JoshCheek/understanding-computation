require 'treetop'
require 'pattern/ast'

module Pattern
  require 'pattern/grammar'
  Parser = PatternGrammarParser

  extend self

  def parse(str)
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
end
