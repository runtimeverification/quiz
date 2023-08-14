/+  *test, quiz
:: this is a sensible property test for the boxcar function from Hoon school homework.
:: https://github.com/sigilante/curriculum/blob/360bea9fdbc085fa43bfdc8d9b23251e454bc1d8/hsl-2023.3/hw.md#deferring-computation
:: the first arm (called `boxcar`) is the boxcar function (i.e. a solution to the homework).
:: if youw want to test your own implementation, go ahead and replace the code with your own.
:: now, what are some good tests for it?
|%
++  boxcar
  |=  x=@ud
  `@ud`|((lte x 3) (gth x 5))
:: one thing we might want to try is to make sure that the output is correctly
:: constrained: i.e. that the result is always either 0 or 1.
:: this is a kind of sanity check. it's not a full specification of everything
:: the function should do, but just an obvious thing that should always be true,
:: which helps us catch bugs early. 
++  test-boxcar-sanity
  :: the specifications we write are called "fate", because it is what a a piece
  :: of code is destined to do, unless something is amiss in the world (a bug).
  =/  fate
  |=  x=@ud             :: we specify that we want any possible @ud value as sample.
  =+  res=(boxcar x)
  |(=(res 0) =(res 1))  :: we check that the result of (boxcar x) is either 0 or 1.
  ::
  :: check:quiz is a gate that will try to find a bug by semi-intelligently looking
  :: for any sample x that will get the fate to return %.n.
  :: if it does (because we wrote a bad boxcar function), quiz will tell us.
  %-  expect  !>  (check:quiz !>(fate) ~ ~) :: we pass the gate called "fate" to quiz.
:: now for some more exact tests. for two values, boxcar will return 1. W
++  test-boxcar-4-5
  %-  expect  !>  &(=(1 (boxcar 4)) =(1 (boxcar 5)))
++  test-boxcar-others
  =/  fate
  |=  x=@ud
  ?:  |(=(x 4) =(x 5))
    :: returning %drop means we didn't pass or fail, we just don't care about the result.
    :: you will be able to see in the dojo how many samples were dropped.
    %drop
  =(0 (boxcar x))
  %-  expect  !>  (check:quiz !>(fate) ~ ~)
--