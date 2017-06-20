require_relative 'simple'

module Simple
  def parse(str)
    tokens, unparsed = tokenize(str)
    raise "Not fully tokenized: #{unparsed.inspect}" if unparsed.length > 0
    asts = []
    while tokens.any?
      ast, tokens = parse_tokens(old_tokens = tokens)
      raise "Unparsed tokens! #{tokens.inspect}" if old_tokens == tokens
      asts << ast
    end
    case asts.length
    when 0 then raise "Haven't figured out what to do with empty programs"
    when 1 then asts[0]
    else asts.reduce { |first, second| Sequence first, second }
    end
  end

  private def parse_tokens(tokens)
    first, second, *rest = tokens

    if "=" == second
      rhs, tokens = parse_tokens(rest)
      return Assign(first.intern, rhs), tokens
    end

    binops = {
      "+" => {class: Add, reassoc: true},
      "-" => {class: Sub, reassoc: true},
      "*" => {class: Mul, reassoc: true},
      "<" => {class: LessThan},
      ">" => {class: GreaterThan},
    }

    if op = binops[second]
      lhs, tokens = parse_tokens([first])
      raise "Invalid LHS" unless tokens.empty?
      rhs, tokens = parse_tokens(rest)
      instance = op[:class].new lhs, rhs
      instance = instance.reassoc if op[:reassoc]
      return instance, tokens
    end

    if "if" == first
      # This might be a good place to introduce parser combinators?
      raise "Not a left paren: #{second.inspect}"  unless "(" == second
      condition, (rparen, lbrace, *tokens) = parse_tokens rest
      raise "Not a right paren: #{rparen.inspect}" unless ")" == rparen
      raise "Not an lbrace: #{lbrace.inspect}"     unless "{" == lbrace
      consequent, (rbrace, kw_else, lbrace, *tokens) = parse_tokens tokens
      raise "Not an rbrace: #{rbrace.inspect}"     unless "}" == rbrace
      raise "Not an else kw: #{kw_else.inspect}"   unless "else" == kw_else
      raise "Not an lbrace: #{lbrace.inspect}"     unless "{" == lbrace
      alternate, (rbrace, *tokens) = parse_tokens tokens
      raise "Not an rbrace: #{rbrace.inspect}"     unless "}" == rbrace
      return If(condition, consequent, alternate), tokens
    end

    if "while" == first
      raise "Not a left paren: #{second.inspect}"  unless "(" == second
      condition, (rparen, lbrace, *tokens) = parse_tokens rest
      raise "Not a right paren: #{rparen.inspect}" unless ")" == rparen
      raise "Not an lbrace: #{lbrace.inspect}"     unless "{" == lbrace
      body, (rbrace, *tokens) = parse_tokens tokens
      raise "Not an rbrace: #{rbrace.inspect}"     unless "}" == rbrace
      return While(condition, body), tokens
    end

    case first
    when /^\d+$/
      return Num(first.to_i), tokens.drop(1)
    when /^\w/
      return Var(first.intern), tokens.drop(1)
    end

    raise "Unparsed tokens: #{tokens.inspect}"
  end

  private def tokenize(str)
    tokens = []
    loop do
      case str
      when /\A\s+/
        str = $'
      when /\A\d+/,
           /\A\w[\w0-9]*/,
           /\A[-+*<>=(){}]/
        tokens << $&
        str = $'
      else
        break
      end
    end
    return tokens, str
  end
end
