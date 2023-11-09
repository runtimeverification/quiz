# What is %quiz

In short, `%quiz` is a property testing library for Hoon.
It will test your code with lots of random values to see if it breaks.

In long, what this means is that you write tests for your code with the help of `%quiz`, which means you will find bugs and fix them.
It's called 'property test' because you write your tests as 'properties': code that should always return `%.y`.
Your job is to think up good properties and test your code against them.
It's a great complement for unit testing.

For example, a property we could state about the `dec` function is that it's the inverse of incrementation (`.+`).
Therefore, decrementing `n` and then incrementing it should give us back `n`. 
In math, all we're saying is that `(n - 1) + 1 = n` .
In Hoon, we say the following:

```
.=  n  .+  (dec n)
```

The way we express these properties is by putting them in a gate.
We express that with the help of our gate, by its sample.
If we want to say "for all atoms `n` ..." in Hoon, we write:

```
|=  n=@
...  :: some property of n
```


---

*Aside:*

If you're into formal logic you know that we are "universally quantifying over `n`".
The formula above in something like Peano logic would look like this. (Where we define a decrement `D` with `D(S(n)) = n`):

```
∀ n ∈ ℕ. n = S(D(n))
```

(If you don't follow this notation don't worry, you can just skip these asides.)

--- 

Let's check this property of `dec`.
First we need to install `%quiz`.
We grab it from my moon, and use `%take-this` to tell Clay that we only want the files in the desk that are not already in `%base` -- this is fine because `%quiz` is just a set of files otherwise not found in `%base`.

```
|merge %base ~mister-dister-bithex-topnym %quiz, =gem %take-this
```

You should see a message of the merging of a number of files: one library, one generator, and some tests.

---

*Aside*

If you know your way around tests already, and you've got some Hoon experience, you could dive into those test files.
They contain comments and examples that should teach you all you need to get going.
If you want an easier introduction you can keep following along in this blog post.

---

```
.=  n  .+  (dec n)
```

We want to quantify it so that it holds over all atoms `n` and test it.

```
|=  n=@
.=  n  .+  (dec n)
```

A note on terminology:
If you just know that a "fate" is a specification and that "norns" can be used to generate input for your spec, you know all you need about `%quiz` terminology.
As the name implies, a fate should describe you what piece of code is destined to do, unless something is amiss in the world (a bug or an incorrect divination where the fate you wrote is not correct).
The terms we use in `%quiz` bring to mind an ancient Viking visiting a seer to find out their fate, what they need to do, and getting help to ensure they are on the right path -- a nice epic image of what testing your code should be like.
They have a fate, they are quizzed on it, they may heed that fate (good) or defy it (bad), and they can use [norns](https://en.wikipedia.org/wiki/Norns) to aid them in seeing if there are any issues.

So we have our fate defined.
We can now quiz it in the dojo.
Call the generator `%quiz`, and give it the fate, as a vase.
To make something into a vase, simply use the rune `!>`.

```
+quiz !>
|=  n=@
.=  n  .+  (dec n)
```

Whoops!
You should have gotten an error.

```
[%err <<"decrement-underflow">>]
[[%defy-with-sam "n=0"] %drops 0]
```

As you may have guessed, some input gave us a decrement underflow.
If you look at the second line, you can see an example of a sample that caused the code to defy it's fate: `n=0`.
And as you can see, running this in the dojo:

```
=/  fate
  |=  n=@
  .=  n  .+  (dec n)
(fate 0)
```

You get a decrement underflow.
And obviously, right?
This is not an error in `dec`: it's an error in the fate we wrote.
Decrementing 0 is an error in Hoon!

Let's fix our fate:
The first way is to exclude the sample 0 (the only one with this issue).
We can do that by "dropping" that sample:

```
|=  n=@
?:  =(n 0)  %drop
.=  n  .+  (dec n)
```

This is quite a useful in many circumstances.
`%quiz` will generate random inputs for you but some of them might be nonsensical for what you are testing.
And just dropping those inputs is the fastest way to deal with it.

The other way to fix our fate is to use "norns" to intelligently create inputs in a way that suits our function.
We'll get to that later.

---

Aside:

In formal logic you may assume that subtraction below 0 in natural numbers is undefined and use `%drop` as a sort of implication:

```
∀ n ∈ ℕ. n =/= 0 => n = S(D(n)
```

Again, if you're not familiar with this vocabulary and notation, just ignore it.

---

Now let's quiz this new fate:

```
+quiz !>
  |=  n=@
  ?:  =(n 0)  %drop
  .=  n  .+  (dec n)
```

Here is what we get:

```
[[%success-runs 100] %drops 1]
%.y
```

This tells you that the given 100 different samples, all of them succeeded, and one of them (the sample `n=0`) was explicitly dropped.

# What is `%quiz` doing?

Let's have a look at the different samples `%quiz` is sending.
The easiest way to do that is to just add some debug printing inside the fate (notice the `~&`):

```
+quiz !>
  |=  n=@
  ~&  n
  ?:  =(n 0)  %drop
  .=  n  .+  (dec n)
```

This prints lots of numbers (100 of them, in fact).
If you read them top to bottom, you will find that they are generally growing in size.
This is just useful heuristic the library uses: if there is a bug, it is usually found at the edge cases of small numbers.
The numbers chosen are random, but the distribution from which they are pulled is growing.

If you run the generator again, you will again see a list of numbers, but this time it will be different numbers.

Try again without the 0-check and see what happens:

```
+quiz !>
  |=  n=@
  ~&  n
  .=  n  .+  (dec n)
```

`%quiz` finds the bug on the first value it tries and reports it.
It doesn't need to finish the 100 runs, it can simply report it back to you without trying more samples.

Random sampling usually works well for quick testing and will find many bugs for you.
It's good enough, most of the time.
However sometimes you want more control over the inputs, some way to generate them yourself, using some randomness
This is where "norns" come in, and we'll get to them later.
For now, let's move past the `+quiz` generator and start using the library, which will give us more expressive power, and also mean that we can work in a Hoon file instead of the dojo.

# Getting quizzical

So first, let's get our test running in a Hoon file.
We will use the same fate as before for simplicity.

You can either start a new desk (`|new-desk %foo` in the dojo) or just use the `%base` desk.
For this example I'll use the `%base` desk.
Mount your desk with `|mount %base` and then locate the `base/` directory in your pier.
Create a new Hoon file: `base/tests/my-test.hoon`.
If you don't have a `base/tests` directory yet just create it.
Now open `my-test.hoon` and create the following contents:

```
:: tests/my-test.hoon
/+  test, quiz
|%
++  test-dec
  =/  fate
    |=  n=@
    ?:  =(n 0)  %drop
    .=  n  .+  (dec n)
  %-  expect:test
  !>  %^  check:quiz
        !>(fate)
      ~
    ~
--
```

A test file should go in the `tests/` directory, and import the `test` library.
Here we also import the `quiz` library.
The rest of the file is a core, created with `|%`.
Every arm (`++`) of that core with a name starting with `test-` will be run once we run this test file.
It's good practice to call the arm something descriptive.
Here we are testing `dec` so `test-dec` is a good name.

We then give our define our fate, binding it to the name `fate`.
This is more readable than just putting it inline with the call to `%quiz` like we did above in the dojo.

Then we call `expect` from the `test` library.
This gate expects a vase (created with `!>`) as sample.
The `expect` family of gates -- `expect`, `expect-eq` and `expect-fail` -- help manage the test runs and make the output readable.
`expect` will simply say that the test passed if it gets the sample `%.y`, and otherwise will say that it failed.
This is useful when we build a large test-suite: if we ran lots of test at the same time and one of them fails, the `test` library using `expect` will tell us at the end something failed, while still running all of them.

So what do we pass as a sample to `expect`?
Simply the result of running `check` from the `quiz` library.
Running `check` will always return a loobean -- `%.y` or `%.n` -- for success or failure, respectively.
`check` takes a triple sample (which we can call with `%^`): a `fate`, and optionally a `norn` and an `alts`, which we'll learn about later.
For now, we just pass `~` for both, which means "use the default settings".

## Running our tests

To run our test, commit your new test file with `|commit %base` in the dojo.
Then run the following:

```
-test /=base=/tests/my-test/hoon
```

That passed?
Good!

Try breaking the test (remove the line that checks if `=(n 0)`) and run the test again.
Did it fail?
Good!

```
built   /tests/my-test/hoon
[ %err
  <<
    "decrement-underflow"
    "/tests/my-test/hoon:<[7 16].[7 23]>"
    "/tests/my-test/hoon:<[7 12].[7 23]>"
    "/tests/my-test/hoon:<[7 5].[7 23]>"
  >>
]
[[%defy-with-sam "n=0"] %drops 0]
>   test-dec: took ms/20.855
FAILED  /tests/my-test/test-dec
expected: %.y
actual  : %.n
```
Note the output: first, there are the error messages from `quiz` telling us what went wrong and where.
Then the final status report from `quiz`, in this case `[[%defy-with-sam "n=0"] %drops 0]` that you've seen before.
Then comes the info from `test` (remember: `test` is running `quiz` here) showing us how long the tests ran, if something failed and what, and what the expected value was (in this case not very interesting, since it's only reporting on the loobean returned from `quiz`).
Finally, under the output, you get a loobean result, telling you whether the test suite as a whole passed or failed.
Since we had one test failing (it only takes one), the test suite failed and the result is `%.n`.

Now, put the check for `=(n 0)` back and commit again.

Since `%quiz` comes with plenty of example tests, this would be a good time to run them and see what the output of a larger test suite might look like.
To do that, we don't specify a specific Hoon file and instead ask the test runner to find and run all test files under the `tests/` directory.

```
-test /===/tests
```

---

Aside: the `+quiz` generator.

Open the `+quiz` generator: `base/gen/quiz.hoon`.
All it does is import the `quiz` library, then run the fate you gave it (`vax`).

```
/+  quiz
:-  %say
|=  [[now=@da eny=@uvJ bec=beak] [vax=vase ~] [runs=@ud ~]]
[%noun (~(check quiz eny runs) vax ~ ~)]
```

As you can see here, `quiz` is actually a door which takes some entropy `eny` and a number of runs `runs` as input.
The defaults are the entropy `0` and 100 runs.
So if you just call `check:quiz` directly, as we did above, you get those defaults.
(If you're not familiar: `~(foo bar a b c ...)` will pass the sample `[a b c ...]` to the door `bar` and give you back the arm `foo`.
So what we are doing here is give the `quiz` library some global parameters, `eny` and `runs`, getting the reference to the `check` arm back, which we then call.
If we instead would have had the last line be `[%noun (check:quiz vax ~ ~)]` then we would have used the default sample `[0 100]`.)

As you can also see, the generator always passes `~` for both the norn and alts (the last arguments to `check`).
There is no way to use more powerful features of the library that we'll cover from the generator: it's just a handy tool to quickly check fates without making a new test file.

--

## Norns: smarter input generation

`%quiz` has built-in support for generating valid samples for most gates -- really any sample that is not a core.
Let's try a few.
Try the following in the dojo, which will just print the different samples when requesting nouns, pairs, and lists:

```
+quiz !>  |=(* ~&(+6 %.y))
+quiz !>  |=((pair @ud ?) ~&(+6 %.y))
+quiz !>  |=((list @) ~&(+6 %.y))
```

Pretty neat!
You should see lots of output for each.
But the lists are a little lackluster.
The default way for `%quiz` to create most data structures unfortunately can't control for length, so most lists you end up with are quite short.
To remedy this you can use an existing norn.
By using the dedicated list norn you get samples of many different sizes.

Norns are combinators.
You can create more complex ones by combining simple primitives.
The simplest norn is the `const` norn, which always just returns a constant value.
Let's try it out.
Add the following arm to your test file:

```
++  test-const
  =/  fate
    |=  n=@
    ~&  n
    .=  n  69
  %-  expect:test
  !>  %^  check:quiz
        !>(fate)
      `((const:norns.quiz @) 69)
    ~
```

The norns take an aura (in this case `@`) and a further sample that tell it how to create random inputs.
The backtick in front of the norn just makes it a unit.
If you run this test, you get back a new kind of result -- `%tired`.
Since `%quiz` keeps track of all the inputs it has tried and only tries them once, it eventually has to give up for this particular example, because the norn only produces a single possible result!
So it's clear that `%quiz` was using our norn.

Norns become important as you work with more complex data structures.
`%quiz` does its best to produce inputs for your gates, but all it has to go on is the Hoon type enclosed in the vase you are passing to it.
Hoon types are very powerful, but hard to inspect.
There is no "list type", for example.
Instead the type is a what is called a `%hold`, which is used to represent almost all data structures with possibly infinite content.
For example, the lists that `%quiz` automatically generate end up being quite short (probability $2^{-1-n}$ for each length `n`).
And the sets end up with possibly duplicate items and strange orders, because nothing in the type expresses that elements are unique.

We could spend a lot of time implementing checks for all common types ...
Or we could simply recognize the fact that for most use cases, all the relevant information is not encoded in the type anyway!
For example, if you write a Gall app, your expected poke may be simple list object with a `%tas` and a `%ud` in them.
But you know roughly what pokes could look like.
They probably can't contain any data whatsoever (and if they do, you have some error handling to throw them out).
If `%quiz` was to randomly generate `%poke`s for your app on its own most of them would be useless, and you'd end up thoroughly testing your error handling for pokes and nothing else.

Thus: if your input requires specific structure than a noun of a particular shape, you probably want to use a norn.
You can write your own norn as a gate.
For example, the following is a norn that returns only sorted lists of `@ud`s.

```
^-  (norn.quiz (list @ud))
|=  [size=@ud rng=_og]
|-
^-  (list @ud)
?:  =(0 size)
  ~
=^  ran  rng  (rads:rng size)
[size $(size ran, rng rng)]
```

The type `norn.quiz` is defined as

```
  |$  [sam]
  $-([@ud _og] sam)
```

So it's a gate taking a `@ud` (a size) and a random number generator, and returning whatever `sam` is.
In our example above, a `(list @ud)`.
So you can use Hoon's type checking to ensure that you are producing samples of the correct type when writing your own norn!

As mentioned above, norns are combinators.
The tutorial test file (named `examples/tests/01-quiz-tutorial.hoon`) in `%quiz` contains plenty of examples of building more complex norns from simpler ones, and lots of comments.
You should now know enough about `%quiz` to look through it.

# Alts

There is one final aspect of `%quiz` that a user should know.
It's not vital, but can help you with debugging when `%quiz` spits out a counterexample, but the counterexample is large.
Just as `%quiz` will do its best to create samples for you, it will also do its best to shrink those examples for you when it encounters them, so that you get the smallest possible example.

For example, consider the following fate:

```
|=  a=@  ?:  (gth a 500)  %.n  %.y
```

If you run this with the `+quiz` generator it will always come back with `a=501` as a sample that defies the fate.
You can try this as many times as you like and you will always see the same result.
How is it possible that it always finds the smallest possible counterexample?

The technique is called "shrinking".
`%quiz` has, for some data types, an ability to suggest a number of smaller alternatives to any given input.
For example, for atoms, when it finds a counterexample `n` it will first try `n/2`.
If it turns out `n/2` is a counterexample, it will try to shrink that further.
If it's not a counterexample, it will try `n-1`.
Again, if `n-1` it was a counterexample it will shrink further from there.
If neither of these was a counterexample, it will consider the job done and return `n`.

For each attempt at shrinking, it will simply pass the new candidate to the gate being tested.
There's no magic here.

Let's look at a sample execution with some print debugging.

```
> +quiz !>  |=  a=@   ~&  a  ?:  (gth a 500)  %.n  %.y
509
254
508
254
507
253
506
253
505
252
504
252
503
251
502
251
501
250
500
[[%defy-with-sam "a=501"] %drops 0]
%.n
```

As you can see, the first counterexample we find is `509`.
From there `%quiz` tries `254` which returns `%.y` and then `508` which returns `%.n`.
So the shrinking will continue with `508`, and the same process will continue.
When it gets to `501`, it will try `250` and `500`, both of which will return `%.y`, so `501` is the smallest counterexample it can find.

If you try this with a pair instead, so the sample is `[a=@ b=@]` for example, you will find that `b` shrinks fast (since it doesn't matter in our example and `%quiz` always try halving first) while `a` shrinks slower, honing in on the right answer.

Now, just as `%quiz` can't produce sensible input for any sample you want, it also can't produce sensible alternatives to all kinds of values.
So `%quiz` gives you control: you can pass an `alts` gate to `check` that will be used to find smaller candidates to whatever failing sample it finds.
Be careful though!
If the alternatives you provide are not strictly "smaller" than the sample in some natural sense you may get an infinite loop.
Don't worry though: since `%quiz` runs deterministically in your test file, you can always just remove the `alts` if you mess up.
You don't have to worry about `%quiz` finding a one-in-a-million bug and then fail to report it because it got stuck shrinking forever.

The alts you pass must be a list of vases, since they will be used as samples and that is what check expects for its inputs.

If alts are a bit on the complicated side, don't worry: they are indeed useful but most of the time `%quiz` will do at least a decent job shrinking, and it's just a tool that will help you if your counterexamples end up being very big.

# End notes

That's it!
You know all you need to know to start testing harder and faster in Hoon.
Download `%quiz` and get started!
And you can always reach out to us at Runtime Verification on either Urbit at ~bithex-topnym, or on [Discord](https://discord.com/invite/CurfmXNtbN) or [Telegram](https://t.me/rv_inc).

# !!! ---- Scratchpad

# Why do we write bugs?

# Tests as documentation

# Programming by contract
    
# A list example

Let's say you implemented a list reverse function (because you forgot about `flop`).
(You can follow along in the dojo if you want.)

```
=rev |*  a=(list)
  ^+  a
  ?~  a  ~
  (weld $(a t.a) ~[i.a])
```

How do you know it's correct?
You could try some examples:

```
> (rev `(list)`~[1 2 3])
~[3 2 1]
> (rev ~)
~
(rev `(list)`~[[1 2] [3 4]])
~[[3 4] [1 2]]
```

Let's try with more examples.

```
> +quiz !>  |*  a=(list)  =(a (rev (rev a)))
%.y
> +quiz !>  |*  [a=(list) b=(list)]  =((rev (weld a b)) (weld (rev b) (rev a)))
%.y
```

You see the printed output

```
[[%success-runs 100] %drops 0]
```

What did that tell you? 
It means `%quiz` generated 100 samples for you, and evaluate the gate you passed it (as a vase).

Why 100?
Why not.
But you can do more if you like with the optional argument `=runs`.

```
> +quiz !>  |*  a=(list)  =(a (rev (rev a))), =runs 1.000
%.y
```

What are these samples that are being generated?
Let's have a look, inserting a `~&` (and reducing the number of runs to make the input manageable).

```
> +quiz !>  |*  a=(list)  ~&  a  =(a (rev (rev a))), =runs 10
```

You'll see a 10 different lists being generated.
