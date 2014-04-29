# xo

[![Gem Version](https://badge.fury.io/rb/xo.svg)](http://badge.fury.io/rb/xo) [![Build Status](https://travis-ci.org/dwayne/xo.svg?branch=master)](https://travis-ci.org/dwayne/xo) [![Coverage Status](https://coveralls.io/repos/dwayne/xo/badge.png)](https://coveralls.io/r/dwayne/xo) [![Code Climate](https://codeclimate.com/github/dwayne/xo.png)](https://codeclimate.com/github/dwayne/xo)

A [Ruby](http://www.ruby-lang.org/en/) library for [Tic-tac-toe](http://en.wikipedia.org/wiki/Tic-tac-toe).

# Performance of the Minimax Algorithm

```ruby
require 'benchmark'
require 'xo'

# Empty grid
g = XO::Grid.new

puts Benchmark.measure { XO::AI.minimax(g, :x) }
# => 0.000000   0.000000   0.000000 (  0.000463)
# => O(1) time due to caching

# One spot taken
g[1, 1] = :x

puts Benchmark.measure { XO::AI.minimax(g, :o) }
# => 0.000000   0.000000   0.000000 (  0.000216)
# => O(1) time due to caching

# Two spots taken
g[1, 3] = :o

puts Benchmark.measure { XO::AI.minimax(g, :x) }
# => 0.690000   0.000000   0.690000 (  0.695095)
# => Worst-case time, performance only improves from here on as the grid gets filled
```

# Testing

You can run:

- All tests: `rake test`
- One test: `ruby -Ilib -Ispec spec/path_to_spec_file.rb`

# TODO

1. Write documentation.
2. Show example usage of the grid, engine and ai subclasses.
3. ~~Write an example Tic-tac-toe command-line game client.~~
4. In the grid class, call what is now `to_s`, `pretty_print` and rewrite `to_s` to be a single one-line string representation.
5. Improve test coverage.

# Contributing

If you'd like to contribute a feature or bugfix: Thanks! To make sure your fix/feature has a high chance of being included, please read the following guidelines:

1. Post a [pull request](https://github.com/dwayne/xo/compare/).
2. Make sure there are tests! I will not accept any patch that is not tested. It's a rare time when explicit tests aren't needed. If you have questions about writing tests for xo, please open a [GitHub issue](https://github.com/dwayne/xo/issues/new).

# License

xo is Copyright © 2014 Dwayne R. Crooks. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
