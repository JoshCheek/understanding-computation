Chapter 4
=========

Pushdown automaata (deterministic and nondeterministic).

This is basically a DFA and NFA with a stack they can use. This lets them store
info outside their set of states, so they could be used to parse HTML, for example.

Nondeterministic is more powerful than deterministic here, because it's free
states combined with the state of the callstack can't be translated into a
deterministic set of rules (you may need to explore multiple sets of rules to
an arbitrary depth before you can determine which path is going to work out).

I'm skipping the code from this section b/c I get it at a high level and don't
find the book's first-principles approach to be very clear (I'd rather it give
me the final interface and acceptance criteria, then let me explore the objects
at each layer that need to exist in order to pull it off). Plus, the code exercise
is a palindrome checker, which just isn't very interesting to me, and a second,
less-good parser for Simple, but I already wrote one of those in ch2.

Really, though, it's the lack of a good acceptance test to illustrate the inputs
and outputs in a way that doesn't span 30 code samples throughout the chapter.
