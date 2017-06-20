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

    klass.module_eval(block) if block
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

  Struct :Add, :lhs, :rhs
  Struct :Sub, :lhs, :rhs
  Struct :Mul, :lhs, :rhs
  Struct :LessThan, :lhs, :rhs
  Struct :GreaterThan, :lhs, :rhs
end
