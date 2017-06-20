module Simple
  extend self

  private def Struct(name, *attrs, &block)
    klass = ::Struct.new(*attrs) do
      def with(overrides)
        overrides.each_with_object(dup) do |(k, v), struct|
          struct[k] = v
        end
      end
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
      klass.singleton_class.class_eval do
        attr_accessor :precedence
      end
    end

    def precedence
      self.class.precedence
    end

    def reassoc
      return self unless rhs.respond_to? :precedence
      if precedence < rhs.precedence
        with rhs: rhs.reassoc
      else
        rhs.reassoc.bubble_down self
      end
    end

    protected def bubble_down(parent)
      if parent.precedence < precedence
        parent.with rhs: self
      elsif lhs.respond_to? :precedence
        with lhs: lhs.bubble_down(parent)
      else
        with lhs: parent.with(rhs: lhs)
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
