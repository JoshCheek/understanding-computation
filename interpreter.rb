require 'pp'

class Machine < Struct.new(:sexp, :env)
  def run
    evaluations = []
    sexp, env = self.sexp, self.env
    loop do
      puts "{#{env.map { |k, v| "#{k}: #{v}" }.join(", ")}}", sexp
      evaluations << [sexp, env]
      break unless sexp.evaluatable?
      sexp, env = sexp.evaluate(env)
    end
    evaluations
  end
end

class Sequence < Struct.new(:exprs)
  def evaluatable?
    true
  end
  def initialize(*exprs)
    super exprs
  end
  def evaluate(env)
    if exprs.empty?
      [DoNothing.new, env]
    elsif exprs[0].evaluatable?
      first, new_env = exprs[0].evaluate(env)
      [Sequence.new(first, *exprs.drop(1)), new_env]
    else
      [Sequence.new(*exprs.drop(1)), env]
    end
  end
  def to_s
    exprs.map(&:to_s).join('; ')
  end
end

class If < Struct.new(:condition, :consequence, :alternate)
  def evaluatable?
    true
  end
  def evaluate(env)
    if condition.evaluatable?
      new_condition, new_env = condition.evaluate(env)
      [If.new(new_condition, consequence, alternate), env]
    elsif condition.true?
      [consequence, env]
    else
      [alternate, env]
    end
  end
  def to_s
    "if(#{condition}) { #{consequence} } else { #{alternate} }"
  end
end

class While < Struct.new(:condition, :body)
  def evaluatable?
    true
  end
  def evaluate(env)
    [If.new(condition, Sequence.new(body, self), DoNothing.new), env]
  end
  def to_s
    "while(#{condition}) { #{body} }"
  end
end

class Value < Struct.new(:value)
  def evaluatable?
    false
  end
  def to_s
    value.to_s
  end
end

class Number < Value
end

class Boolean < Value
  def true?
    value == true
  end
end

class Variable < Struct.new(:name)
  def evaluatable?
    true
  end
  def evaluate(env)
    [env.fetch(name), env]
  end
  def to_s
    name.to_s
  end
end

class Assign < Struct.new(:name, :value)
  def evaluatable?
    true
  end
  def evaluate(env)
    if value.evaluatable?
      new_value, new_env = value.evaluate(env)
      [Assign.new(name, new_value), new_env]
    else
      [DoNothing.new, env.merge(name => value)]
    end
  end
  def to_s
    "#{name} = #{value}"
  end
end

class DoNothing
  def evaluatable?
    false
  end
  def to_s
    'NOOP'
  end
end

BinaryOp = Struct.new(:lhs, :rhs) do
  class << self
    attr_accessor :operator, :result_class
  end
  def to_s
    "#{lhs} #{self.class.operator} #{rhs}"
  end
  def evaluatable?
    true
  end
  def evaluate(env)
    if lhs.evaluatable?
      new_lhs, new_env = lhs.evaluate(env)
      [self.class.new(new_lhs, rhs), new_env]
    elsif rhs.evaluatable?
      new_rhs, new_env = rhs.evaluate(env)
      [self.class.new(lhs, new_rhs), new_env]
    else
      raw_value = lhs.value.public_send(self.class.operator, rhs.value)
      value = self.class.result_class.new raw_value
      [value, env]
    end
  end
end

class LessThan < BinaryOp
  self.operator = :<
  self.result_class = Boolean
end

class Multiply < BinaryOp
  self.operator = :*
  self.result_class = Number
end

class Add < BinaryOp
  self.operator = :+
  self.result_class = Number
end


Machine.new(
  Sequence.new(
    If.new(
      LessThan.new(Number.new(1), Number.new(2)),
      Assign.new(:x, Number.new(1)),
      Assign.new(:x, Number.new(2)),
    ),
    If.new(
      LessThan.new(Number.new(2), Number.new(1)),
      Assign.new(:x, Multiply.new(Variable.new(:x),Multiply.new(Variable.new(:y), Number.new(2)))),
      Assign.new(:x, Multiply.new(Variable.new(:x),Multiply.new(Variable.new(:y), Number.new(3)))),
    ),
    While.new(
      LessThan.new(Variable.new(:x), Number.new(10)),
      Assign.new(:x, Add.new(Variable.new(:x), Number.new(1))),
    ),
  ),
  {y: Number.new(2)}
).run

# >> {y: 2}
# >> if(1 < 2) { x = 1 } else { x = 2 }; if(2 < 1) { x = x * y * 2 } else { x = x * y * 3 }; while(x < 10) { x = x + 1 }
# >> {y: 2}
# >> if(true) { x = 1 } else { x = 2 }; if(2 < 1) { x = x * y * 2 } else { x = x * y * 3 }; while(x < 10) { x = x + 1 }
# >> {y: 2}
# >> x = 1; if(2 < 1) { x = x * y * 2 } else { x = x * y * 3 }; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> NOOP; if(2 < 1) { x = x * y * 2 } else { x = x * y * 3 }; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> if(2 < 1) { x = x * y * 2 } else { x = x * y * 3 }; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> if(false) { x = x * y * 2 } else { x = x * y * 3 }; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> x = x * y * 3; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> x = 1 * y * 3; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> x = 1 * 2 * 3; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> x = 1 * 6; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 1}
# >> x = 6; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 6}
# >> NOOP; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 6}
# >> while(x < 10) { x = x + 1 }
# >> {y: 2, x: 6}
# >> if(x < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 6}
# >> if(6 < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 6}
# >> if(true) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 6}
# >> x = x + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 6}
# >> x = 6 + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 6}
# >> x = 7; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 7}
# >> NOOP; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 7}
# >> while(x < 10) { x = x + 1 }
# >> {y: 2, x: 7}
# >> if(x < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 7}
# >> if(7 < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 7}
# >> if(true) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 7}
# >> x = x + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 7}
# >> x = 7 + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 7}
# >> x = 8; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 8}
# >> NOOP; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 8}
# >> while(x < 10) { x = x + 1 }
# >> {y: 2, x: 8}
# >> if(x < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 8}
# >> if(8 < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 8}
# >> if(true) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 8}
# >> x = x + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 8}
# >> x = 8 + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 8}
# >> x = 9; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 9}
# >> NOOP; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 9}
# >> while(x < 10) { x = x + 1 }
# >> {y: 2, x: 9}
# >> if(x < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 9}
# >> if(9 < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 9}
# >> if(true) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 9}
# >> x = x + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 9}
# >> x = 9 + 1; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 9}
# >> x = 10; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 10}
# >> NOOP; while(x < 10) { x = x + 1 }
# >> {y: 2, x: 10}
# >> while(x < 10) { x = x + 1 }
# >> {y: 2, x: 10}
# >> if(x < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 10}
# >> if(10 < 10) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 10}
# >> if(false) { x = x + 1; while(x < 10) { x = x + 1 } } else { NOOP }
# >> {y: 2, x: 10}
# >> NOOP
# >> {y: 2, x: 10}
# >>
# >> {y: 2, x: 10}
# >> NOOP
# >> {y: 2, x: 10}
# >>
# >> {y: 2, x: 10}
# >> NOOP
# >> {y: 2, x: 10}
# >>
# >> {y: 2, x: 10}
# >> NOOP
# >> {y: 2, x: 10}
# >>
# >> {y: 2, x: 10}
# >> NOOP
# >> {y: 2, x: 10}
# >>
# >> {y: 2, x: 10}
# >> NOOP
