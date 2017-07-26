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
(succ => (add => (n0 => (n1 => (n3 => (n5 => (n10 => (n15 => (n30 => (n60 => (n100 =>
(_B => (_F => (_i => (_u => (_z =>
(TRUE => (FALSE => (IF => (AND =>
(y => (DO =>
(cons => (head => (tail => (isEmpty => (nil => (count =>
(pred => (isZero => (sub => (numEq => (lt => (mod =>
  DO // TESTS
    (_=>ASSERT_EQUAL('a', IF(TRUE)(_=>'a')(_=>'b')))
    (_=>ASSERT_EQUAL('b', IF(FALSE)(_=>'a')(_=>'b')))
    (_=>ASSERT_EQUAL(2, TO_I(mod(n5)(n3))))
    (_=>ASSERT_EQUAL(3, TO_I(mod(n3)(n5))))
    (_=>ASSERT_EQUAL(10, TO_I(mod(n100)(n15))))
    (_=>ASSERT_EQUAL(100, TO_I(n100)))
    (_=>ASSERT_EQUAL(4, pred(n5)(n => n + 1)(0)))
    (_=>ASSERT_EQUAL(10, TO_I(sub(n15)(n5))))
    (_=>ASSERT_EQUAL(122, TO_I(_z)))
    (_=>ASSERT(TO_BOOL(AND(TRUE)(TRUE))))
    (_=>REFUTE(TO_BOOL(AND(TRUE)(FALSE))))
    (_=>REFUTE(TO_BOOL(AND(FALSE)(TRUE))))
    (_=>REFUTE(TO_BOOL(AND(FALSE)(FALSE))))
    (_=>ASSERT(TO_BOOL(numEq(n0)(n0))))
    (_=>REFUTE(TO_BOOL(numEq(n1)(n0))))
    (_=>REFUTE(TO_BOOL(numEq(n0)(n1))))
    (_=>ASSERT(TO_BOOL(numEq(n5)(n5))))
    (_=>REFUTE(TO_BOOL(numEq(n3)(n1))))
    (_=>REFUTE(TO_BOOL(lt(n3)(n3))))
    (_=>REFUTE(TO_BOOL(lt(n5)(n5))))
    (_=>ASSERT(TO_BOOL(lt(n3)(n5))))
    (_=>REFUTE(TO_BOOL(lt(n5)(n3))))
    (_=>ASSERT_EQUAL('a', head(cons('a')(cons('b')(cons('c')(nil))))))
    (_=>ASSERT_EQUAL('b', head(tail(cons('a')(cons('b')(cons('c')(nil)))))))
    (_=>ASSERT_EQUAL('c', head(tail(tail(cons('a')(cons('b')(cons('c')(nil))))))))
    (_=>ASSERT_EQUAL(3, TO_I(count(cons('a')(cons('b')(cons('c')(nil)))))))
    // FIZZ BUZZ
    (_=>(fizzbuzz => fizzbuzz(n1)(n100))
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
)(// mod
  y(recur => n1 => n2 =>
    IF(lt(n1)(n2))
      (_=>n1)
      (_=>recur(sub(n1)(n2))(n2)))
))(y(recur => nA => nB => isZero(sub(nB)(nA))(FALSE)(TRUE)) // lt
))(// numEq
  nA => nB =>
    AND(isZero(sub(nA)(nB)))
       (isZero(sub(nB)(nA)))
))(nA => nB => nB(pred)(nA) // sub
))(n => n(_ => FALSE)(TRUE) // isZero
))(// pred
  n => f => arg =>
    n(pair => pair(isFirst => value => _empty =>
        IF(isFirst)
          (_=>cons(FALSE)(value))
          (_=>cons(FALSE)(f(value)))))
     (cons(TRUE)(arg))
     (isFirst => value => _empty => value)
))(// count
  y(recur =>
    list =>
      IF(isEmpty(list))
        (_=>n0)
        (_=>succ(recur(tail(list)))))
))(f => f(_=>_)(_=>_)(TRUE)                                          // nil
))(list => list(head => tail => empty => empty)                      // isempty
))(list => list(head => tail => empty => tail)                       // tail
))(list => list(head => tail => empty => head)                       // head
))(a => b => f => f(a)(b)(FALSE)                                     // cons
))(y(recur => a => b => recur((_=>_=>_)(b(a(_=>_)))))                // DO
))(// Y combinator
  f =>
    (builder => arg => f(builder(builder))(arg))
    (builder => arg => f(builder(builder))(arg))
))(a => b => a(b)(a)                                                 // AND
))(bool => trueCase => falseCase => bool(trueCase)(falseCase)(_=>_)  // IF
))(trueCase => falseCase => falseCase                                // FALSE
))(trueCase => falseCase => trueCase                                 // TRUE
))(add(_u)(n5)                                                       // _z (122)
))(add(add(n100)(n15))(add(n1)(n1))                                  // _u (117)
))(add(n100)(n5)                                                     // _i (105)
))(add(n60)(n10)                                                     // _F (70)
))(add(add(n60)(n5))(n1)                                             // _B (66)
))(add(n10)(add(n30)(n60))                                           // 100
))(add(n30)(n30)                                                     // 60
))(add(n15)(n15)                                                     // 30
))(add(n5)(n10)                                                      // 15
))(add(n5)(n5)                                                       // 10
))(succ(succ(n3))                                                    // 5
))(succ(succ(n1))                                                    // 3
))(succ(n0)                                                          // 1
))(f => arg => arg                                                   // 0
))(nA => nB => f => arg => nA(f)(nB(f)(arg))                         // add
))(n => f => arg => n(f)(f(arg))                                     // succ
)
