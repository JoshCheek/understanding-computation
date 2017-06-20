require_relative 'parse'

RSpec.configure do |config|
  config.fail_fast = true
  config.formatter = 'documentation'
end

RSpec.describe 'parsing' do
  include Simple

  def parses!(to_parse, expected_ast)
    expect(parse to_parse).to eq(expected_ast)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    e.set_backtrace caller.drop(1)
    raise
  end

  it 'can parse numbers' do
    parses! '1', Num(1)
    parses! '1234567890', Num(1234567890)
  end

  it 'can parse variables' do
    parses! 'x', Var(:x)
    parses! 'abcdefghijklmnopqrstuvwxyz', Var(:abcdefghijklmnopqrstuvwxyz)
    parses! 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', Var(:ABCDEFGHIJKLMNOPQRSTUVWXYZ)
    parses! 'a1', Var(:a1)
  end

  it 'can parse addition' do
    parses! '1+2',   Add(Num(1), Num(2))
    parses! '3 + 4', Add(Num(3), Num(4))
  end

  it 'can parse subtraction' do
    parses! '1-2',   Sub(Num(1), Num(2))
    parses! '3 - 4', Sub(Num(3), Num(4))
  end

  it 'can parse multiplication' do
    parses! '1*2',   Mul(Num(1), Num(2))
    parses! '3 * 4', Mul(Num(3), Num(4))
  end

  it 'can parse less-than' do
    parses! '1<2',   LessThan(Num(1), Num(2))
    parses! '3 < 4', LessThan(Num(3), Num(4))
  end

  it 'can parse greater-than' do
    parses! '1>2',   GreaterThan(Num(1), Num(2))
    parses! '3 > 4', GreaterThan(Num(3), Num(4))
  end

  it 'can parse assignment' do
    parses! 'a = 1', Assign(:a, Num(1))
    parses! 'a = 1+5', Assign(:a, Add(Num(1), Num(5)))
  end

  it 'can parse nested structures' do
    parses! '1 + 2 + 3', Add(Add(Num(1), Num(2)), Num(3))
    parses! '1 - 2 - 3', Sub(Sub(Num(1), Num(2)), Num(3))
    parses! '1 * 2 * 3', Mul(Mul(Num(1), Num(2)), Num(3))
  end

  it 'gives addition and subtraction the same precedence' do
    parses! '1 + 2 - 3', Sub(Add(Num(1), Num(2)), Num(3))
    parses! '1 - 2 + 3', Add(Sub(Num(1), Num(2)), Num(3))
    parses! '1 - 2 + 3 - 4', Sub(Add(Sub(Num(1), Num(2)), Num(3)), Num(4))
    parses! '1 + 2 - 3 + 4', Add(Sub(Add(Num(1), Num(2)), Num(3)), Num(4))
  end

  it 'gives multiplication higher precedence than addition and subtraction' do
    parses! '1 + 2 * 3', Add(Num(1), Mul(Num(2), Num(3)))
    parses! '1 * 2 + 3', Add(Mul(Num(1), Num(2)), Num(3))
    parses! '1 - 2 * 3', Sub(Num(1), Mul(Num(2), Num(3)))
    parses! '1 * 2 - 3', Sub(Mul(Num(1), Num(2)), Num(3))
    parses! '1 + 2 * 3 - 4',
      Sub(Add(Num(1), Mul(Num(2), Num(3))), Num(4))
    parses! '1*2 - 3*4 + 5*6', Add(
                                 Sub(
                                   Mul(Num(1), Num(2)),
                                   Mul(Num(3), Num(4))),
                                 Mul(Num(5), Num(6)))
  end

  it 'can parse if-statements' do
    parses! "if( 1<2 ) { 3 } else { 4 }", If(
      LessThan(Num(1), Num(2)),
      Num(3),
      Num(4),
    )
    parses! "if(1<2){3}else{4}", If(
      LessThan(Num(1), Num(2)),
      Num(3),
      Num(4),
    )
    parses! "if\n(\n1\n<\n2\n)\n{\n3\n}\nelse\n{\n4\n}\n", If(
      LessThan(Num(1), Num(2)),
      Num(3),
      Num(4),
    )
  end

  it 'can parse while-statements' do
    parses! "while( i < 5 ) { i = i + 1 }", While(
      LessThan(Var(:i), Num(5)),
      Assign(:i, Add(Var(:i), Num(1)))
    )
  end

  it 'can parse across lines' do
    parses! "1 + \n2", Add(Num(1), Num(2))
    parses! "1\n + 2", Add(Num(1), Num(2))
  end

  xit 'can parse sequences' do
    parses! "1\n2", Sequence(Num(1), Num(2))
    parses! "a\nb\nc", Sequence(Var(:a), Var(:b), Var(:c))
  end

  xit 'can parse all that shit' do
    expected = Sequence(
      Assign(:x, Mul(Var(:x), Num(2))),
      Sequence(
        Assign(:y, Add(Var(:y), Num(15))),
        Sequence(
          If(LessThan(Var(:x), Var(:y)),
             Assign(:z, Add(Var(:x), Var(:y))),
             Assign(:z, Sub(Var(:x), Var(:y)))),
          Sequence(
            Assign(:i, Num(0)),
            While(
              GreaterThan(Num(5), Var(:i)),
              Assign(:i, Add(Var(:i), Num(1))))
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
