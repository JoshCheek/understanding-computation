require 'pattern'
RSpec.configure do |config|
  config.color     = true
  config.fail_fast = true
  config.formatter = 'documentation'
end

module Pattern
  RSpec.describe 'Pattern.parse' do
    include Pattern

    def parses!(str, expected)
      actual = Pattern.parse(str)
      expect(actual).to eq Pattern::Top.new(expected)
    end

    specify 'empty string -> EOS' do
      parses! "", Eos.new
    end

    specify 'a single alphanumeric char -> ExactMatch' do
      [*"a".."z", *"A".."Z", *"0".."9"].each do |char|
        parses! char.dup, ExactMatch.new(char.dup)
      end
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

    specify 'parens -> Group'

    specify 'asterisks to ZeroOrMore of whatever is to the left' do
      parses! 'a*', ZeroOrMore.new(ExactMatch.new("a"))
    end

    specify 'asterisks bind higher than sequences' do
      parses! 'ab*', Sequence.new(
        ExactMatch.new("a"),
        ZeroOrMore.new(ExactMatch.new("b"))
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
      parses! 'a(b|c)*d', Sequence.new(
        ExactMatch.new("a"),
        Sequence.new(
          ZeroOrMore.new(
            Group.new(
              Either.new(
                ExactMatch.new("b"),
                ExactMatch.new("c"),
              )
            )
          ),
          ExactMatch.new("d"),
        )
      )
    end
  end
end
