require_relative 'simple'

module Simple
  def parse(str)
    tokens, unparsed = tokenize(str)
    return parse_tokens *tokens if unparsed.empty?
    raise "Not fully parsed: #{unparsed.inspect}"
  end

  private def parse_tokens(*tokens)
    if tokens.length == 0
      require "pry"
      binding.pry
    end

    if tokens.length == 1
      case token = tokens.first
      when /^\d+$/
        Number token.to_i
      else
        Variable token.intern
      end
    elsif tokens.length == 3
      first, second, third = tokens
      case second
      when "+"
        Add parse_tokens(first), parse_tokens(third)
      when "-"
        Sub parse_tokens(first), parse_tokens(third)
      when "*"
        Multiply parse_tokens(first), parse_tokens(third)
      when "<"
        LessThan parse_tokens(first), parse_tokens(third)
      when ">"
        GreaterThan parse_tokens(first), parse_tokens(third)
      else
        raise "Missing binary op? #{tokens.inspect}"
      end
    else
      require "pry"
      binding.pry
    end
  end

  private def tokenize(str)
    tokens = []
    loop do
      case str
      when /^\s+/
        # noop
      when /^\d+/, /^\w[\w0-9]*/, /[-+*<>]/
        tokens << $&
      else
        break
      end
      str = str.sub $&, ""
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
