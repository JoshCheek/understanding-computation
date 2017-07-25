// INTEROP (translates lambda calculus into JavaScript)
const PRINT = toPrint => console.log(toPrint)
const TO_I  = lambdaInt => lambdaInt(n => n + 1)(0)

;
// LAMBDA CALCULUS
(succ => (add => (n0 => (n1 => (n3 => (n5 => (n15 => (n100 =>
(TRUE => (FALSE => (IF =>
(y =>
(mod =>
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
  // console.log(TO_I(mod(n5)(n3)));
  console.log(IF(TRUE)(_=>'t!')(_=>'f!'))
  console.log(IF(FALSE)(_=>'t!')(_=>'f!'))
  console.log(TO_I(n100));
})(
  y(recur => n1 => n2 =>
    IF(lt(n1)(n2))(_=>n1)(_=>recur(sub(n1)(n2))(n2))
  )
))(
  // y combinator
  f =>
    (builder => arg => f(builder(builder))(arg))
    (builder => arg => f(builder(builder))(arg))
))(bool => trueCase => falseCase => bool(trueCase)(falseCase)(_=>_) // IF
))(trueCase => falseCase => falseCase                               // FALSE
))(trueCase => falseCase => trueCase                                // TRUE
))((n30 => add(add(n5)(n5))(add(n30)(add(n30)(n30))))(add(n15)(n15)) // 100
))(add(n5)(add(n5)(n5))          // 15
))(succ(succ(n3))                // 5
))(succ(succ(n1))                // 3
))(succ(n0)                      // 1
))(f => arg => arg               // 0
))(nA => nB => f => arg => nA(f)(nB(f)(arg)) // add
))(n => f => arg => n(f)(f(arg)) // succ
)
