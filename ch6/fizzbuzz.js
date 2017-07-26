// INTEROP (translates lambda calculus into JavaScript)
const PUTS    = lambdaStr  => console.log(TO_S(lambdaStr))
const TO_S    = lambdaStr  => TO_ARY(lambdaStr).map(TO_CHR).join('')
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

// TEST ASSERTIONS
const util    = require('util')
const ASSERT  = bool => { if(!bool) throw(`Expected ${bool} to be true`) }
const REFUTE  = bool => { if(bool) throw(`Expected ${bool} to be false`) }
const ASSERT_EQUAL = (expected, actual) => {
  if(expected !== actual)
    throw(`Expected ${util.inspect(expected)} to === ${util.inspect(actual)}`)
}

// LAMBDA CALCULUS
(compose => (succ => (add =>
(n0 => (n1 => (n2 => (n3 => (n4 => (n5 => (n6 => (n7 => (n8 => (n9 => (n10 =>
(n15 => (n30 => (n60 => (n100 =>
($0 => ($1 => ($2 => ($3 => ($4 => ($5 => ($6 => ($7 => ($8 => ($9 =>
($B => ($F => ($i => ($u => ($z =>
(TRUE => (FALSE => (IF => (AND =>
(y => (DO =>
(cons => (head => (tail => (isEmpty => (nil => (map => (reduce => (count => (reverse =>
(pred => (isZero => (sub => (numEq => (lt => (mod => (div =>
(intToStr => (str =>

  DO // TESTS
    (_=>ASSERT_EQUAL('a', IF(TRUE)(_=>'a')(_=>'b')))
    (_=>ASSERT_EQUAL('b', IF(FALSE)(_=>'a')(_=>'b')))
    (_=>ASSERT_EQUAL(2, TO_I(mod(n5)(n3))))
    (_=>ASSERT_EQUAL(3, TO_I(mod(n3)(n5))))
    (_=>ASSERT_EQUAL(10, TO_I(mod(n100)(n15))))
    (_=>ASSERT_EQUAL(100, TO_I(n100)))
    (_=>ASSERT_EQUAL(4, pred(n5)(n => n + 1)(0)))
    (_=>ASSERT_EQUAL(10, TO_I(sub(n15)(n5))))
    (_=>ASSERT_EQUAL(122, TO_I($z)))
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
    (_=>ASSERT_EQUAL('dcba', TO_ARY(reverse(cons('a')(cons('b')(cons('c')(cons('d')(nil)))))).join('')))
    (_=>ASSERT_EQUAL('F', TO_CHR($F)))
    (_=>ASSERT_EQUAL('', TO_ARY(map(TO_CHR)(str(n0))).join('')))
    (_=>ASSERT_EQUAL(4, TO_I(count(str($F)($i)($z)($z)(n0)))))
    (_=>ASSERT_EQUAL('Fizz', TO_ARY(map(TO_CHR)(str($F)($i)($z)($z)(n0))).join('')))
    (_=>ASSERT_EQUAL('zziF', TO_ARY(map(TO_CHR)(reverse(str($F)($i)($z)($z)(n0)))).join('')))
    (_=>ASSERT_EQUAL(20, TO_I(div(n100)(n5))))
    (_=>ASSERT_EQUAL(3, TO_I(div($i)(n30))))
    (_=>ASSERT_EQUAL('30', TO_ARY(map(TO_CHR)(intToStr(n30))).join('')))
    (_=>ASSERT_EQUAL('105', TO_ARY(map(TO_CHR)(intToStr($i))).join('')))

    // FIZZ BUZZ
    (_=>(fizzbuzz => fizzbuzz(n1)(n100))
        (y(recur => i => max =>
          IF(numEq(i)(max))
            (_=>_) // base case
            (_=>
              DO(_=>
                IF(isZero(mod(i)(n15)))
                (_=>PUTS(str($F)($i)($z)($z)($B)($u)($z)($z)(n0)))
                  (_=>IF(isZero(mod(i)(n5)))
                    (_=>PUTS(str($F)($i)($z)($z)(n0)))
                    (_=>IF(isZero(mod(i)(n3)))
                      (_=>PUTS(str($B)($u)($z)($z)(n0)))
                      (_=>PUTS(intToStr(i))))))
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
))(// intToStr
  (digitToChar => (intToStrReverse =>
    compose(intToStrReverse)(reverse)
  )((y(recur => n =>
       IF(lt(n)(n10))
         (_=>cons(digitToChar(n))(nil))
         (_=>cons(digitToChar(mod(n)(n10)))(recur(div(n)(n10)))))))
  )(digit =>
    IF(numEq(n0)(digit))(_=>$0)
    (_=>IF(numEq(n1)(digit))(_=>$1)
    (_=>IF(numEq(n2)(digit))(_=>$2)
    (_=>IF(numEq(n3)(digit))(_=>$3)
    (_=>IF(numEq(n4)(digit))(_=>$4)
    (_=>IF(numEq(n5)(digit))(_=>$5)
    (_=>IF(numEq(n6)(digit))(_=>$6)
    (_=>IF(numEq(n7)(digit))(_=>$7)
    (_=>IF(numEq(n8)(digit))(_=>$8)
                            (_=>$9))))))))))
))(// div
  y(recur => n1 => n2 =>
    IF(lt(n1)(n2))
      (_=>n0)
      (_=>succ(recur(sub(n1)(n2))(n2))))
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
))(// reverse
  y(recur => list =>
    reduce(newList => head => cons(head)(newList))(list)(nil))
))(list => reduce(n=>_e=>succ(n))(list)(n0)                          // count
))(// reduce
  y(recur =>
    f => list => memo =>
      IF(isEmpty(list))
        (_=>memo)
        (_=>recur(f)
                 (tail(list))
                 (f(memo)(head(list)))))
))(// map
  y(recur =>
    f => list =>
      IF(isEmpty(list))
        (_=>nil)
        (_=>cons(f(head(list)))
                (recur(f)(tail(list)))))
))(f => f(_=>_)(_=>_)(TRUE)                                          // nil
))(list => list(head => tail => empty => empty)                      // isempty
))(list => list(head => tail => empty => tail)                       // tail
))(list => list(head => tail => empty => head)                       // head
))(head => tail => chooser => chooser(head)(tail)(FALSE)             // cons
))(y(recur => a => b => recur((_=>_=>_)(b(a(_=>_)))))                // DO
))(// Y combinator
  f =>
    (builder => arg => f(builder(builder))(arg))
    (builder => arg => f(builder(builder))(arg))
))(a => b => a(b)(a)                                                 // AND
))(bool => trueCase => falseCase => bool(trueCase)(falseCase)(_=>_)  // IF
))(trueCase => falseCase => falseCase                                // FALSE
))(trueCase => falseCase => trueCase                                 // TRUE
))(add($u)(n5)                                                       // $z (122)
))(add(add(n100)(n15))(n2)                                           // $u (117)
))(add(n100)(n5)                                                     // $i (105)
))(add(n60)(n10)                                                     // $F (70)
))(add(n60)(n6)                                                      // $B (66)
))(succ($8)                                                          // $9 (57)
))(succ($7)                                                          // $8 (56)
))(succ($6)                                                          // $7 (55)
))(succ($5)                                                          // $6 (54)
))(succ($4)                                                          // $5 (53)
))(succ($3)                                                          // $4 (52)
))(succ($2)                                                          // $3 (51)
))(succ($1)                                                          // $2 (50)
))(succ($0)                                                          // $1 (49)
))(add(add(n30)(n15))(n3)                                            // $0 (48)
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
))(f1 => f2 => arg => f2(f1(arg))                                    // compose
)
