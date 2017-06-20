module Simple
  extend self

  private def Struct(name, *attrs, &block)
    klass = ::Struct.new(*attrs) do
      def class_name
        self.class.name.to_s.sub(/^Simple::/, "")
      end
      def to_s
        "#{class_name}(#{values.join ', '})"
      end
      alias inspect to_s
    end

    klass.module_eval(&block) if block
    const_set name, klass
    define_method(name) { |*args| klass.new(*args) }
    klass
  end

  Struct :Num, :value
  Struct :Var, :name
  Struct :Assign, :name, :value
  Struct :Sequence, :first, :second
  Struct :If, :condition, :consequent, :alternate
  Struct :While, :condition, :body

  module BinaryOp
    def self.included(klass)
      class << klass
        attr_accessor :precedence
      end
    end

    def precedence
      self.class.precedence
    end

    def reassoc
      return self unless rhs.respond_to? :precedence
      if precedence >= rhs.precedence
        rhs.reassoc.binop_flip self
      else
        self.class.new(lhs, rhs.reassoc)
      end
    end

    protected def binop_flip(parent)
      (rhs.respond_to?(:precedence) &&
         rhs.precedence >= precedence ?
        rhs.binop_flip(self)        :
        self
      ).push_down_lhs(parent)
    end

    protected def push_down_lhs(parent)
      if precedence > parent.precedence
        parent.class.new(
          parent.lhs,
          self
        )
      elsif lhs.respond_to? :precedence
        self.class.new(
          lhs.push_down_lhs(parent),
          rhs
        )
      else
        self.class.new(
          parent.class.new(parent.lhs, lhs),
          rhs
        )
      end
    end
  end

  Struct :Add, :lhs, :rhs do
    include BinaryOp
    self.precedence = 1
  end

  Struct :Sub, :lhs, :rhs do
    include BinaryOp
    self.precedence = 1
  end

  Struct :Mul, :lhs, :rhs do
    include BinaryOp
    self.precedence = 2
  end

  Struct :LessThan, :lhs, :rhs
  Struct :GreaterThan, :lhs, :rhs
end
