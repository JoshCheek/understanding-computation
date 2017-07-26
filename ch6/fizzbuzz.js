// INTEROP (translates lambda calculus into JavaScript)
const PUTS    = str => console.log(TO_ARY(str).map(TO_CHR).join(''))
const TO_I    = lambdaInt  => lambdaInt(n => n + 1)(0)
const TO_BOOL = lambdaBool => lambdaBool(true)(false)
const TO_CHR  = lambdaChar => String.fromCharCode(TO_I(lambdaChar))
const TO_ARY  = lambdaList => {
  let ary = []
  while(lambdaList(_ => _ => empty => !TO_BOOL(empty))) {
    ary.push(lambdaList(head => _ => _ => head))
    lambdaList = lambdaList(_ => tail => _ => tail)
  }
  return ary
}
// const TO_STRING = lambdaStr  =>
//   map(lambdaStr)(chr => TO_I(chr))

// TEST ASSERTIONS
const util    = require('util')
const ASSERT  = bool => { if(!bool) throw(`Expected ${bool} to be true`) }
const REFUTE  = bool => { if(bool) throw(`Expected ${bool} to be false`) }
const ASSERT_EQUAL = (expected, actual) => {
  if(expected !== actual)
    throw(`Expected ${util.inspect(expected)} to === ${util.inspect(actual)}`)
}

// LAMBDA CALCULUS
(succ => (add =>
(n0 => (n1 => (n2 => (n3 => (n4 => (n5 => (n6 => (n7 => (n8 => (n9 => (n10 =>
(n15 => (n30 => (n60 => (n100 =>
(_B => (_F => (_i => (_u => (_z =>
(TRUE => (FALSE => (IF => (AND =>
(y => (DO =>
(cons => (head => (tail => (isEmpty => (nil => (count => (map =>
(pred => (isZero => (sub => (numEq => (lt => (mod =>
(str =>
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
    (_=>ASSERT_EQUAL('abc', TO_ARY(cons('a')(cons('b')(cons('c')(nil)))).join('')))
    (_=>ASSERT_EQUAL('ABC', TO_ARY(map(chr => chr.toUpperCase())(cons('a')(cons('b')(cons('c')(nil))))).join('')))
    (_=>ASSERT_EQUAL('F', TO_CHR(_F)))
    (_=>ASSERT_EQUAL('', TO_ARY(map(TO_CHR)(str(n0))).join('')))
    (_=>ASSERT_EQUAL(4, TO_I(count(str(_F)(_i)(_z)(_z)(n0)))))
    (_=>ASSERT_EQUAL('Fizz', TO_ARY(map(TO_CHR)(str(_F)(_i)(_z)(_z)(n0))).join('')))
    // FIZZ BUZZ
    (_=>(fizzbuzz => fizzbuzz(n1)(n100))
        (y(recur => i => max =>
          IF(numEq(i)(max))
            (_=>_) // base case
            (_=>
              DO(_=>
                IF(isZero(mod(i)(n15)))
                (_=>PUTS(str(_F)(_i)(_z)(_z)(_B)(_u)(_z)(_z)(n0)))
                  (_=>IF(isZero(mod(i)(n5)))
                    (_=>PUTS(str(_F)(_i)(_z)(_z)(n0)))
                    (_=>IF(isZero(mod(i)(n3)))
                      (_=>PUTS(str(_B)(_u)(_z)(_z)(n0)))
                      (_=>PUTS(str(_z)(_z)(_z)(n0))))))
                      // (_=>PUTS(TO_I(i))))))
              (_=>recur(succ(i))(max))))))
)(// str
  (getRest => maybeChr =>
    IF(isZero(maybeChr))
      (_=>nil)
      (_=>getRest(rest => cons(maybeChr)(rest)))
  )(y(recur => cb => maybeChr =>
    IF(isZero(maybeChr))
      (_=>cb(nil))
      (_=>recur(rest => cb(cons(maybeChr)(rest))))))
))(// mod
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
))(// map
  y(recur =>
    f => list =>
      IF(isEmpty(list))
        (_=>nil)
        (_=>cons(f(head(list)))
                (recur(f)(tail(list)))))
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
))(add(add(n100)(n15))(n2)                                           // _u (117)
))(add(n100)(n5)                                                     // _i (105)
))(add(n60)(n10)                                                     // _F (70)
))(add(n60)(n6)                                                      // _B (66)
))(add(n10)(add(n30)(n60))                                           // 100
))(add(n30)(n30)                                                     // 60
))(add(n15)(n15)                                                     // 30
))(add(n5)(n10)                                                      // 15
))(succ(n9)                                                          // 10
))(succ(n8)                                                          // 9
))(succ(n7)                                                          // 8
))(succ(n6)                                                          // 7
))(succ(n5)                                                          // 6
))(succ(n4)                                                          // 5
))(succ(n3)                                                          // 4
))(succ(n2)                                                          // 3
))(succ(n1)                                                          // 2
))(succ(n0)                                                          // 1
))(f => arg => arg                                                   // 0
))(nA => nB => f => arg => nA(f)(nB(f)(arg))                         // add
))(n => f => arg => n(f)(f(arg))                                     // succ
)
