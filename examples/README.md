Here are examples of how you can use %quiz to test gates you might know from Hoon School.

To test them, put them in your ship, under a desk where you have cloned/copied the %quiz library, in the `tests` folder.
For example, if you have `quiz.hoon` and `test.hoon` in the `lib` folder of your %base desk:

```
base
├── lib
│   ├── quiz.hoon
│   └── test.hoon
└── tests
    ├── boxcar.hoon
    └── euler.hoon
```

Then, from the dojo, run the following:

```
dojo> -test /=base=/tests
```

Remember to change the desk name (in this case `base`) according to which desk you are working in.

These example use the built-in testing library in Urbit, in addition to %quiz.
You can learn more about that testing library here: [https://developers.urbit.org/guides/core/hoon-school/I-testing](https://developers.urbit.org/guides/core/hoon-school/I-testing)
