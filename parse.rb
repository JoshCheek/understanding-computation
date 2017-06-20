require_relative 'simple'

module Simple
  def parse(str)
    tokens, unparsed = tokenize(str)
    return parse_tokens tokens if unparsed.empty?
    raise "Not fully parsed: #{unparsed.inspect}"
  end

  private def parse_tokens(tokens)
    if tokens.length == 0
      require "pry"
      binding.pry
    end

    if tokens.length == 1
      case token = tokens.first
      when /^\d+$/
        Num token.to_i
      else
        Var token.intern
      end
    elsif tokens.length == 2
      require "pry"
      binding.pry
    else
      first, second, *rest = tokens
      case second
      when "+"
        rhs = parse_tokens(rest)
        case rhs
        when Add, Sub
          rhs.class.new Add(parse_tokens([first]), rhs.lhs), rhs.rhs
        else
          Add parse_tokens([first]), rhs
        end
      when "-"
        rhs = parse_tokens(rest)
        case rhs
        when Add, Sub
          rhs.class.new Sub(parse_tokens([first]), rhs.lhs), rhs.rhs
        else
          Sub parse_tokens([first]), rhs
        end
      when "*"
        rhs = parse_tokens(rest)
        case rhs
        when Mul
          Mul Mul(parse_tokens([first]), rhs.lhs), rhs.rhs
        else
          Mul parse_tokens([first]), rhs
        end

      when "<"
        LessThan parse_tokens([first]), parse_tokens(rest)
      when ">"
        GreaterThan parse_tokens([first]), parse_tokens(rest)
      when "="
        Assign first.intern, parse_tokens(rest)
      else
        raise "Missing binary op? #{tokens.inspect}"
      end
    end
  end

  private def tokenize(str)
    tokens = []
    loop do
      case str
      when /\A\s+/
        # noop
      when /\A\d+/, /\A\w[\w0-9]*/, /\A[-+*<>=]/
        tokens << $&
      else
        break
      end
      str = $'
    end
    return tokens, str
  end
end

__END__
x = x * 2
y = y + 15
if(x < y) {
  z = x + y
} else {
  z = x - y
}
i = 0
while(5 > i) {
  i = i + 1
}
SIMPLE
