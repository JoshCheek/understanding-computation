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
    elsif "=" == tokens[1]
      Assign tokens[0].intern, parse_tokens(tokens.drop 2)
    else
      first, second, *rest = tokens
      lhs_ast, rhs_ast = parse_tokens([first]), parse_tokens(rest)
      case second
      when "+"
        Add(lhs_ast, rhs_ast).reassoc
      when "-"
        Sub(lhs_ast, rhs_ast).reassoc
      when "*"
        Mul(lhs_ast, rhs_ast).reassoc
      when "<"
        LessThan lhs_ast, rhs_ast
      when ">"
        GreaterThan lhs_ast, rhs_ast
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
