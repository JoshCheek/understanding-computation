// INTEROP (translates lambda calculus into JavaScript)

// LAMBDA CALCULUS
function fizzBuzz(i, max) {
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
  fizzBuzz(i+1, max)
}
fizzBuzz(1, 100)
