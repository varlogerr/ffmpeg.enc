Available variables and functions:
* `TESTDIR` - tests directory
* `TEST_MOCKDIR` - tests common mock directory
* `TESTFILE` - current suit test file path
* `SUITDIR` - current suit directory
* `SETUPFILE` - current suit setup file path
* `SUIT_MOCKDIR` - current suit mock directory
* `SUITNAME` - current suit name (without `suit.` prefix)
* `assert_result` - function that allows
  assertions. See demo below.

Rules for definitions:
* suit files are sourced inside a function. If
  you want to limit visibility for other tests
  follow same rules as inside functions
  (for example prefix vars with `local`). That
  doesn't apply to non-suit files (like global)
  `mock`s
* PATH for suites is altered. For each suit it
  has added `${TEST_MOCKDIR}/bin` and
  `${SUIT_MOCKDIR}/bin` directories. It can
  test absense of some utilities or simulate
  their action (for example in cases when they
  make changes in the file system). See
  `${TEST_MOCKDIR}/bin/dummy-grep` for example.
  `PATH_ORIGIN` preserves the original `PATH`
  value

`assert_result` usage demo:
```sh
# arguments:
# * RC expected
# * RC actual
# * text expected
# * text actual
# * log message
# this function call will result in
# function RC `0` and log message:
# ```
# OK: All is ok
# ```
assert_result 0 0 "" "" "All is ok"

# this function call will result in
# function RC `1` and log message:
# ```
# ERR: All is ok
#   Text expected:
#     something
#   Text actual:
#     nothing
# ```
assert_result 0 0 "something" "nothing" "All is ok"

# this function call will result in
# function RC `1` and log message:
# ```
# ERR: All is ok
#   RC expected: 0
#   RC actual: 1
# ```
assert_result 0 1 "nothing" "nothing" "All is ok"

# export `TESTER_ERR=''` variable to view only
# error messages
export TESTER_ERR=''
assert_result 1 0 "" "" "Dummy"

# export `TESTER_DIFF=''` for side by side error
# texts diff
export TESTER_DIFF=''
assert_result 0 0 "nothine" "something" "Dummy"
```
