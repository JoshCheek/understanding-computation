// INTEROP (translates lambda calculus into JavaScript)

// LAMBDA CALCULUS
y = f =>
  (builder => arg => f(builder(builder))(arg))
  (builder => arg => f(builder(builder))(arg))


y(recur => i => max => {
  if(i == max)
    return
  else if(i%15 == 0)
    console.log('FizzBuzz')
  else if(i%5 == 0)
    console.log('Fizz')
  else if(i%3 == 0)
    console.log('Buzz')
  else
    console.log(i)
  recur(i+1)(max)
})(1)(100)
