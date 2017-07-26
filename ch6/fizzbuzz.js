// INTEROP (translates lambda calculus into JavaScript)
const PRINT   = toPrint => console.log(toPrint)
const TO_I    = lambdaInt => lambdaInt(n => n + 1)(0)
const TO_BOOL = lambdaBool => lambdaBool(true)(false)

// TEST ASSERTIONS
const util    = require('util')
const ASSERT  = bool => { if(!bool) throw(`Expected ${bool} to be true`) }
const REFUTE  = bool => { if(bool) throw(`Expected ${bool} to be false`) }
const ASSERT_EQUAL = (expected, actual) => {
  if(expected !== actual)
    throw(`Expected ${util.inspect(expected)} to === ${util.inspect(actual)}`)
}

// LAMBDA CALCULUS
(succ => (add => (n0 => (n1 => (n3 => (n5 => (n15 => (n100 =>
(TRUE => (FALSE => (IF => (AND =>
(cons =>
(DO => (y =>
(pred => (isZero => (sub => (numEq => (lt => (mod =>
  DO
    (_=> { // TESTS
      ASSERT_EQUAL('a', IF(TRUE)(_=>'a')(_=>'b'))
      ASSERT_EQUAL('b', IF(FALSE)(_=>'a')(_=>'b'))
      ASSERT_EQUAL(2, TO_I(mod(n5)(n3)));
      ASSERT_EQUAL(3, TO_I(mod(n3)(n5)));
      ASSERT_EQUAL(10, TO_I(mod(n100)(n15)));
      ASSERT(cons(true)(false)(a => b => a))
      ASSERT(cons(false)(true)(a => b => b))
      ASSERT_EQUAL(100, TO_I(n100));
      ASSERT_EQUAL(4, pred(n5)(n => n + 1)(0))
      ASSERT_EQUAL(10, TO_I(sub(n15)(n5)))
      ASSERT(TO_BOOL(AND(TRUE)(TRUE)))
      REFUTE(TO_BOOL(AND(TRUE)(FALSE)))
      REFUTE(TO_BOOL(AND(FALSE)(TRUE)))
      REFUTE(TO_BOOL(AND(FALSE)(FALSE)))
      ASSERT(TO_BOOL(numEq(n0)(n0)))
      REFUTE(TO_BOOL(numEq(n1)(n0)))
      REFUTE(TO_BOOL(numEq(n0)(n1)))
      ASSERT(TO_BOOL(numEq(n5)(n5)))
      REFUTE(TO_BOOL(numEq(n3)(n1)))
      REFUTE(TO_BOOL(lt(n3)(n3)))
      REFUTE(TO_BOOL(lt(n5)(n5)))
      ASSERT(TO_BOOL(lt(n3)(n5)))
      REFUTE(TO_BOOL(lt(n5)(n3)))})
    (_=> // FIZZ BUZZ
      (fizzbuzz => fizzbuzz(n1)(n100))
      (y(recur => i => max =>
        IF(numEq(i)(max))
          (_=>_) // base case
          (_=>
            DO(_=>
              IF(isZero(mod(i)(n15)))
                (_=>PRINT('FizzBuzz'))
                (_=>IF(isZero(mod(i)(n5)))
                  (_=>PRINT('Fizz'))
                  (_=>IF(isZero(mod(i)(n3)))
                    (_=>PRINT('Buzz'))
                    (_=>PRINT(TO_I(i))))))
            (_=>recur(succ(i))(max))))))
)(
  // mod
  y(recur => n1 => n2 =>
    IF(lt(n1)(n2))(_=>n1)(_=>recur(sub(n1)(n2))(n2))
  )
))(
  // lt
  y(recur => nA => nB =>
    isZero(sub(nB)(nA))(FALSE)(TRUE))
))( // numEq
  nA => nB =>
    AND(isZero(sub(nA)(nB)))
       (isZero(sub(nB)(nA)))
))( nA => nB => nB(pred)(nA) // sub
))(n => n(_ => FALSE)(TRUE) // isZero
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
))(a => b => b(a(_=>_))                                              // DO
))(a => b => f => f(a)(b)                                            // cons
))(a => b => a(b)(a)                                                 // AND
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
