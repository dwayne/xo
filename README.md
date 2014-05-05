# xo

[![Gem Version](https://badge.fury.io/rb/xo.svg)](http://badge.fury.io/rb/xo) [![Build Status](https://travis-ci.org/dwayne/xo.svg?branch=master)](https://travis-ci.org/dwayne/xo) [![Coverage Status](https://coveralls.io/repos/dwayne/xo/badge.png)](https://coveralls.io/r/dwayne/xo) [![Code Climate](https://codeclimate.com/github/dwayne/xo.png)](https://codeclimate.com/github/dwayne/xo)

A [Ruby](http://www.ruby-lang.org/en/) library for [Tic-tac-toe](http://en.wikipedia.org/wiki/Tic-tac-toe).

# Performance of the Minimax Algorithm

```ruby
require 'benchmark'
require 'xo/ai/minimax'

puts Benchmark.measure { XO::AI::Minimax.instance }
# => 3.620000   0.000000   3.620000 (  3.621734)
```

# Testing

You can run:

- All specs: `bundle exec rake`, or
- A specific spec: `bundle exec ruby -Ilib -Ispec spec/path_to_spec_file.rb`

# Contributing

If you'd like to contribute a feature or bugfix: Thanks! To make sure your fix/feature has a high chance of being included, please read the following guidelines:

1. Post a [pull request](https://github.com/dwayne/xo/compare/).
2. Make sure there are tests! I will not accept any patch that is not tested. It's a rare time when explicit tests aren't needed. If you have questions about writing tests for xo, please open a [GitHub issue](https://github.com/dwayne/xo/issues/new).

# License

xo is Copyright © 2014 Dwayne R. Crooks. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
