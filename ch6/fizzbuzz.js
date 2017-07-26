// INTEROP (translates lambda calculus into JavaScript)
const PRINT   = toPrint => console.log(toPrint)
const TO_I    = lambdaInt => lambdaInt(n => n + 1)(0)
const TO_BOOL = lambdaBool => lambdaBool(true)(false)
const ASSERT  = bool => { if(!bool) throw(`Expected ${bool} to be true`) }
const ASSERT_EQUAL = (expected, actual) => {
  if(expected !== actual)
    throw(`Expected ${util.inspect(expected)} to === ${util.inspect(actual)}`)
}

;

// LAMBDA CALCULUS
(succ => (add => (n0 => (n1 => (n3 => (n5 => (n15 => (n100 =>
(TRUE => (FALSE => (IF =>
(cons =>
(y =>
(pred => (sub => (lt => (mod =>
  {
  // y(recur => i => max => {
  //   if(i == max)
  //     return
  //   else if(i%15 == 0)
  //     PRINT('FizzBuzz')
  //   else if(i%5 == 0)
  //     PRINT('Fizz')
  //   else if(i%3 == 0)
  //     PRINT('Buzz')
  //   else
  //     PRINT(i)
  //   recur(i+1)(max)
  // })(1)(100);

  // tests
  ASSERT_EQUAL('a', IF(TRUE)(_=>'a')(_=>'b'))
  ASSERT_EQUAL('b', IF(FALSE)(_=>'a')(_=>'b'))
  // console.log(TO_I(mod(n5)(n3)));
  ASSERT(cons(true)(false)(a => b => a))
  ASSERT(cons(false)(true)(a => b => b))
  ASSERT_EQUAL(100, TO_I(n100));
  ASSERT_EQUAL(4, pred(n5)(n => n + 1)(0))
  // console.log(TO_BOOL(lt(n3)(n3)));
  // console.log(TO_BOOL(lt(n5)(n5)));
  // console.log(TO_BOOL(lt(n3)(n5)));
  // console.log(TO_BOOL(lt(n5)(n3)));
})(
  // mod
  y(recur => n1 => n2 =>
    IF(lt(n1)(n2))(_=>n1)(_=>recur(sub(n1)(n2))(n2))
  )
))(
  // lt
  y(recur => nA => nB =>
  IF(numEq(n0)(nA))(
    _=>IF(numEq(n0)(nB))(FALSE)(TRUE)
  )(
    _=>IF(numEq(n0)(nB))(FALSE)(recur(pred(nA))(pred(nB)))
  ))
))( 'FIXME' // sub
))(
  // pred
  n => f => arg =>
    n(pair => pair(isFirst => value =>
        IF(isFirst)
          (_=>cons(FALSE)(value))
          (_=>cons(FALSE)(f(value)))))
     (cons(TRUE)(arg))
     (isFirst => value => value)
))(
  // y combinator
  f =>
    (builder => arg => f(builder(builder))(arg))
    (builder => arg => f(builder(builder))(arg))
))(a => b => f => f(a)(b) // cons
))(bool => trueCase => falseCase => bool(trueCase)(falseCase)(_=>_)  // IF
))(trueCase => falseCase => falseCase                                // FALSE
))(trueCase => falseCase => trueCase                                 // TRUE
))((n30 => add(add(n5)(n5))(add(n30)(add(n30)(n30))))(add(n15)(n15)) // 100
))(add(n5)(add(n5)(n5))          // 15
))(succ(succ(n3))                // 5
))(succ(succ(n1))                // 3
))(succ(n0)                      // 1
))(f => arg => arg               // 0
))(nA => nB => f => arg => nA(f)(nB(f)(arg)) // add
))(n => f => arg => n(f)(f(arg)) // succ
)
