require_relative 'simple'

module Simple
  def parse(str)
    tokens, unparsed = tokenize(str)
    raise "Not fully tokenized: #{unparsed.inspect}" if unparsed.length > 0
    asts = []
    loop do
      break if tokens.empty?
      ast, tokens = parse_tokens tokens
      asts << ast
    end
    case asts.length
    when 0
      require "pry"
      binding.pry
    when 1
      asts[0]
    else
      asts.reduce { |first, second| Sequence first, second }
    end
  end

  private def parse_tokens(tokens)
    first, second, *rest = tokens

    case second
    when "="
      rhs, tokens = parse_tokens(rest)
      return Assign(first.intern, rhs), tokens
    when "+"
      lhs, tokens = parse_tokens([first])
      raise "Invalid LHS" unless tokens.empty?
      rhs, tokens = parse_tokens(rest)
      return Add(lhs, rhs).reassoc, tokens
    when "-"
      lhs, tokens = parse_tokens([first])
      raise "Invalid LHS" unless tokens.empty?
      rhs, tokens = parse_tokens(rest)
      return Sub(lhs, rhs).reassoc, tokens
    when "*"
      lhs, tokens = parse_tokens([first])
      raise "Invalid LHS" unless tokens.empty?
      rhs, tokens = parse_tokens(rest)
      return Mul(lhs, rhs).reassoc, tokens
    when "<"
      lhs, tokens = parse_tokens([first])
      raise "Invalid LHS" unless tokens.empty?
      rhs, tokens = parse_tokens(rest)
      return LessThan(lhs, rhs), tokens
    when ">"
      lhs, tokens = parse_tokens([first])
      raise "Invalid LHS" unless tokens.empty?
      rhs, tokens = parse_tokens(rest)
      return GreaterThan(lhs, rhs), tokens
    end

    if "if" == first
      # This might be a good place to introduce parser combinators?
      raise "Not a left paren: #{second.inspect}" unless "(" == second
      condition, tokens = parse_tokens rest
      rparen, lbrace, *tokens = tokens
      raise "Not a right paren: #{rparen.inspect}" unless ")" == rparen
      raise "Not an lbrace: #{lbrace.inspect}" unless "{" == lbrace
      consequent, tokens = parse_tokens tokens
      rbrace, kw_else, lbrace, *tokens = tokens
      raise "Not an rbrace: #{rbrace.inspect}" unless "}" == rbrace
      raise "Not an else kw: #{kw_else.inspect}" unless "else" == kw_else
      raise "Not an lbrace: #{lbrace.inspect}" unless "{" == lbrace
      alternate, tokens = parse_tokens tokens
      rbrace, *tokens = tokens
      raise "Not an rbrace: #{rbrace.inspect}" unless "}" == rbrace
      return If(condition, consequent, alternate), tokens
    end

    if "while" == first
      raise "Not a left paren: #{second.inspect}" unless "(" == second
      condition, tokens = parse_tokens rest
      rparen, lbrace, *tokens = tokens
      raise "Not a right paren: #{rparen.inspect}" unless ")" == rparen
      raise "Not an lbrace: #{lbrace.inspect}" unless "{" == lbrace
      body, tokens = parse_tokens tokens
      rbrace, *tokens = tokens
      raise "Not an rbrace: #{rbrace.inspect}" unless "}" == rbrace
      return While(condition, body), tokens
    end

    case first
    when /^\d+$/
      return Num(first.to_i), tokens.drop(1)
    when /^\w/
      return Var(first.intern), tokens.drop(1)
    end
    raise "Tokens: #{tokens.inspect}"

  end

  private def tokenize(str)
    tokens = []
    loop do
      case str
      when /\A\s+/
        # noop
      when /\A\d+/,
           /\A\w[\w0-9]*/,
           /\A[-+*<>=(){}]/
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
if(x < y) {
  z = x + y
} else {
  z = x - y
}
while(5 > i) {
  i = i + 1
}
