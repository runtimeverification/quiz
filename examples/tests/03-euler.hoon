/+  *test, quiz
|%
++  euler
:: produces a set of primes if given one of Euler's lucky numbers: 1, 2, 3, 5, 11, 17, or 41.
:: from homework 5 in Hoon School.
:: https://github.com/sigilante/curriculum/blob/360bea9fdbc085fa43bfdc8d9b23251e454bc1d8/hsl-2023.3/hw.md#hw5
  |=  n=@
  ?<  =(0 n)
  ^-  (list @)
 :: ~&  n
  ?:  =(n 0)
    ~
  :: We will build the list backwards, to make tail-recursion easy.
  =/  k=@  (dec n)
  =|  result=(list @)
  |-  ^-  (list @)
  ?:  =(k 0)
    result
  =/  prime=@  (add (sub (pow k 2) k) n)
  $(result [prime result], k (dec k)) 
::
:: now we want to test the euler gate.
::
++  is-prime
  :: naive primality checker
  |=  a=@
  ?:  (lth a 2)
    :: a < 2 => false
    |
  =/  b  2
  |-
  ?:  (gth (pow b 2) a)
    ::  we checked all numbers for which b*b <= a
    &
  ?:  =((mod a b) 0)
    :: divisible by b
    |
  $(b +(b))
::
:: let's test our primality checker!
::
++  test-is-prime-some
  :: we check that is-prime will at least return %.y for some samples.
  =/  fate
  |=  x=@ud
  ?!  (is-prime x)
  %+  expect-eq  !>(|)  !>((check:quiz !>(fate) ~ ~))
++  test-is-true-prime
  :: here's an example of using %quiz recursively.
  :: we generate numbers, check if our primality checker marks them as prime,
  :: and if so try to find a proper divisor.
  =/  fate
    :: naive: if a is prime (according to our function), see if b is a divisor.
    |=  a=@
    ?.  (is-prime a)
      %drop
    :: test random numbers: is there a divisor?
    =/  fate
      |=  b=@
      ?:  |((gte b a) (lth b 2))
        %drop
      ?!  =((mod a b) 0)
    :: check that b doesn't have divisors other than 0 or itself.
    (check:quiz !>(fate) ~ ~)
  %-  expect  !>  (check:quiz !>(fate) ~ ~)
++  test-euler-property
  =/  lucky  ~[1 2 3 5 11 17 41]
  =/  fate
  |=  a=@
  ?:  =(a 0)
    %drop
  =/  eulers  (euler a)
  :: (find a b) returns ~ if the list a is not a sublist of b.
  ?~  (find ~[a] lucky)
    :: if not lucky number, there is one item in the list which is not prime.
    :: (lien a b) checks that some item in list a doesn't conform to property b.
  (lien eulers |=(b=@ ?!((is-prime b))))
  :: if it's a lucky number, all items are prime.
  :: (levy a b) checks that all items in list a conform to property b.
  (levy eulers is-prime)
  %-  expect  !>  (check:quiz !>(fate) ~ ~)
:: and some unit tests for good measure.
++  test-euler-unit
  ;:  weld
  %+  expect-eq
    !>  ~
    !>  (euler 1)
  %+  expect-eq
    !>  ~[2]
    !>  (euler 2)
  %+  expect-eq
    !>  ~[3 5]
    !>  (euler 3)
  %+  expect-eq
    !>  ~[11 13 17 23 31 41 53 67 83 101]
    !>  (euler 11)
  %-  expect-fail
    |.  (euler 0)
  ==
--
