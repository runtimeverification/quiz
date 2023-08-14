# quiz
A randomized property testing library for Hoon.

# Start Here

1. Write your Hoon app
2. Install %quiz
3. Run tests with random inputs

# Install

## With Dojo

Pick an existing desk, for example `%my-dev-desk` to install %quiz into.

```
dojo> merge %my-dev-desk ~mister-dister-bithex-topnym %quiz, =gem %take-this
```

Check that the installation worked

```
dojo> +my-dev-desk!quiz !> |=(a=@ =((dec +(a)) a))
```

## Manual install

Copy the contents of the lib/ and gen/ directories into your desk.

# Getting started

Look at the `examples/` to see how to use %quiz. 
The source files are filled with comments and you can load them onto your ship, run and modify them.
