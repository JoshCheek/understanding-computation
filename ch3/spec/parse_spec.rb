require 'pattern'
require 'spec_helper'

module Pattern::Ast
  RSpec.describe 'Pattern.parse' do

    def parses!(str, expected)
      actual = Pattern.parse(str)
      expect(actual).to eq Top.new(expected)
    end

    specify 'empty string -> EOS' do
      parses! "", Eos.new
    end

    specify 'a single alphanumeric char -> ExactMatch' do
      [*"a".."z", *"A".."Z", *"0".."9"].each do |char|
        parses! char.dup, ExactMatch.new(char.dup)
      end
    end

    specify 'escaped characters -> ExactMatch' do
      parses! "\\(" , ExactMatch.new("(")
      parses! "\\)" , ExactMatch.new(")")
      parses! "\\[" , ExactMatch.new("[")
      parses! "\\]" , ExactMatch.new("]")
      parses! "\\{" , ExactMatch.new("{")
      parses! "\\}" , ExactMatch.new("}")
      parses! "\\a",  ExactMatch.new("\a")
      parses! "\\b",  ExactMatch.new("\b")
      parses! "\\e",  ExactMatch.new("\e")
      parses! "\\f",  ExactMatch.new("\f")
      parses! "\\n",  ExactMatch.new("\n")
      parses! "\\r",  ExactMatch.new("\r")
      parses! "\\t",  ExactMatch.new("\t")
      parses! "\\v",  ExactMatch.new("\v")
    end

    specify 'multiple characters -> Sequence of ExactMatch' do
      parses! "abcd", Sequence.new(
        ExactMatch.new("a"),
        Sequence.new(
          ExactMatch.new("b"),
          Sequence.new(
            ExactMatch.new("c"),
            ExactMatch.new("d"),
          )
        )
      )
    end

    specify 'asterisks to ZeroOrMore of whatever is to the left' do
      parses! 'a*', ZeroOrMore.new(ExactMatch.new("a"))
    end

    specify 'plusses to OneOrMore of whatever is to the left' do
      parses! 'a+', OneOrMore.new(ExactMatch.new('a'))
    end

    specify 'question marks to Optional of whatever is to the left' do
      parses! 'a?', Optional.new(ExactMatch.new('a'))
    end

    specify 'modifiers bind higher than sequences' do
      parses! 'ab*', Sequence.new(
        ExactMatch.new("a"),
        ZeroOrMore.new(ExactMatch.new("b")),
      )
      parses! 'ab+', Sequence.new(
        ExactMatch.new("a"),
        OneOrMore.new(ExactMatch.new("b")),
      )
      parses! 'ab?', Sequence.new(
        ExactMatch.new("a"),
        Optional.new(ExactMatch.new("b")),
      )
      parses! 'a*b', Sequence.new(
        ZeroOrMore.new(ExactMatch.new("a")),
        ExactMatch.new("b"),
      )
      parses! 'a*b*', Sequence.new(
        ZeroOrMore.new(ExactMatch.new("a")),
        ZeroOrMore.new(ExactMatch.new("b")),
      )
      parses! 'a?b?', Sequence.new(
        Optional.new(ExactMatch.new("a")),
        Optional.new(ExactMatch.new("b")),
      )
    end

    specify 'pipes to Either' do
      parses! "a|b", Either.new(
        ExactMatch.new("a"),
        ExactMatch.new("b"),
      )
      parses! "a|b|c", Either.new(
        ExactMatch.new("a"),
        Either.new(
          ExactMatch.new("b"),
          ExactMatch.new("c"),
        )
      )
    end

    specify 'sequences bind tighter than pipes' do
      parses! "ab|cd", Either.new(
        Sequence.new(
          ExactMatch.new("a"),
          ExactMatch.new("b"),
        ),
        Sequence.new(
          ExactMatch.new("c"),
          ExactMatch.new("d"),
        ),
      )
    end

    specify 'parens -> group' do
      parses! "(a)", Group.new(ExactMatch.new("a"))
    end

    specify 'groups can be in sequences' do
      parses! "a(b)", Sequence.new(
        ExactMatch.new("a"),
        Group.new(ExactMatch.new("b")),
      )
      parses! "(a)b", Sequence.new(
        Group.new(ExactMatch.new("a")),
        ExactMatch.new("b"),
      )
      parses! "(a)(b)", Sequence.new(
        Group.new(ExactMatch.new("a")),
        Group.new(ExactMatch.new("b")),
      )
    end

    specify 'groups can be nested' do
      parses! "((a))", Group.new(Group.new(ExactMatch.new("a")))
    end

    specify 'modifiers can apply to groups' do
      parses! "(a)*", ZeroOrMore.new(Group.new(ExactMatch.new("a")))
    end

    specify 'modifiers apply within groups' do
      parses! "(a*)", Group.new(ZeroOrMore.new(ExactMatch.new("a")))
    end

    specify 'parens bind tighter than sequenes' do
      parses! "a(bc)d", Sequence.new(
        ExactMatch.new("a"),
        Sequence.new(
          Group.new(
            Sequence.new(
              ExactMatch.new("b"),
              ExactMatch.new("c"),
            ),
          ),
          ExactMatch.new("d"),
        )
      )
    end

    specify 'can deal with this kinda complex thing' do
      parses! 'a(b|c*)*d', Sequence.new(
        ExactMatch.new("a"),
        Sequence.new(
          ZeroOrMore.new(
            Group.new(
              Either.new(
                ExactMatch.new("b"),
                ZeroOrMore.new(ExactMatch.new("c")),
              )
            )
          ),
          ExactMatch.new("d"),
        )
      )
    end

    specify 'can deal with this other kinda complex thing' do
      parses! 'ab(c*d|ef)', Sequence.new(
        ExactMatch.new("a"),
        Sequence.new(
          ExactMatch.new("b"),
          Group.new(
            Either.new(
              Sequence.new(
                ZeroOrMore.new(ExactMatch.new("c")),
                ExactMatch.new("d"),
              ),
              Sequence.new(
                ExactMatch.new("e"),
                ExactMatch.new("f"),
              )
            )
          )
        )
      )
    end
  end
end
