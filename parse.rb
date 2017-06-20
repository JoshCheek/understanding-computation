require_relative 'simple'

module Simple
  def parse(str)
    token = str
    case token
    when /^\d+$/
      Number token.to_i
    else
      Variable token.intern
    end
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
