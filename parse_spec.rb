require_relative 'parse'

RSpec.configure do |config|
  config.fail_fast = true
end

RSpec.describe 'parsing' do
  include Simple

  def parses!(to_parse, expected_ast)
    expect(parse to_parse).to eq expected_ast
  end

  it 'can parse numbers' do
    parses! '1', Number(1)
    parses! '1234567890', Number(1234567890)
  end

  it 'can parse variables' do
    parses! 'x', Variable(:x)
    parses! 'abcdefghijklmnopqrstuvwxyz', Variable(:abcdefghijklmnopqrstuvwxyz)
    parses! 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', Variable(:ABCDEFGHIJKLMNOPQRSTUVWXYZ)
    parses! 'a1', Variable(:a1)
  end

  it 'can parse addition' do
    parses! '1+2',   Add(Number(1), Number(2))
    parses! '3 + 4', Add(Number(3), Number(4))
  end

  it 'can parse subtraction' do
    parses! '1-2',   Sub(Number(1), Number(2))
    parses! '3 - 4', Sub(Number(3), Number(4))
  end

  it 'can parse multiplication' do
    parses! '1*2',   Multiply(Number(1), Number(2))
    parses! '3 * 4', Multiply(Number(3), Number(4))
  end

  it 'can parse less-than' do
    parses! '1<2',   LessThan(Number(1), Number(2))
    parses! '3 < 4', LessThan(Number(3), Number(4))
  end

  it 'can parse greater-than' do
    parses! '1>2',   GreaterThan(Number(1), Number(2))
    parses! '3 > 4', GreaterThan(Number(3), Number(4))
  end

  it 'can parse assignment'
  it 'can parse if-statements'
  it 'can parse while-statements'
  it 'can parse sequences'

  it 'can parse all that shit' do
    expected = Sequence(
      Assign(:x, Multiply(Variable(:x), Number(2))),
      Sequence(
        Assign(:y, Add(Variable(:y), Number(15))),
        Sequence(
          If(LessThan(Variable(:x), Variable(:y)),
             Assign(:z, Add(Variable(:x), Variable(:y))),
             Assign(:z, Sub(Variable(:x), Variable(:y)))),
          Sequence(
            Assign(:i, Number(0)),
            While(
              GreaterThan(Number(5), Variable(:i)),
              Assign(:i, Add(Variable(:i), Number(1))))
          )
        )
      )
    )
    expect(parse <<-SIMPLE).to eq expected
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
  end
end
