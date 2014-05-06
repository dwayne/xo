# xo

[![Gem Version](https://badge.fury.io/rb/xo.svg)](http://badge.fury.io/rb/xo) [![Build Status](https://travis-ci.org/dwayne/xo.svg?branch=master)](https://travis-ci.org/dwayne/xo) [![Coverage Status](https://coveralls.io/repos/dwayne/xo/badge.png)](https://coveralls.io/r/dwayne/xo) [![Code Climate](https://codeclimate.com/github/dwayne/xo.png)](https://codeclimate.com/github/dwayne/xo)

A [Ruby](http://www.ruby-lang.org/en/) library for [Tic-tac-toe](http://en.wikipedia.org/wiki/Tic-tac-toe).

The code is well documented and fully tested, so please have a [read of the documentation](http://rubydoc.info/github/dwayne/xo) and take a [look at the tests](https://github.com/dwayne/xo/tree/master/spec/xo). If you're interested to see my [sublime](https://www.google.tt/search?q=define%3A+sublime) (in my humble opinion :sunglasses:) implementation of the [Minimax algorithm](http://en.wikipedia.org/wiki/Minimax#Minimax_algorithm_with_alternate_moves) then view it [here](https://github.com/dwayne/xo/blob/master/lib/xo/ai/minimax.rb#L23). It uses the concept of a [geometric grid](https://github.com/dwayne/xo/blob/master/lib/xo/ai/geometric_grid.rb) to acheive its speed up.

## Example usage

Managing the grid yourself.

```ruby
require 'xo'

include XO

g = Grid.new('xx oo')

puts g # =>  x | x |
       #    ---+---+---
       #     o | o |
       #    ---+---+---
       #       |   |

Evaluator.analyze(g, Grid::X) # => { status: :ok }

g[1, 3] = Grid::X
Evaluator.analyze(g, Grid::X) # => { status: :game_over, type: :winner, details: [{ where: :row, index: 1, positions: [[1, 1], [1, 2], [1, 3]] }] }
Evaluator.analyze(g, Grid::O) # => { status: :game_over, type: :loser, details: [{ where: :row, index: 1, positions: [[1, 1], [1, 2], [1, 3]] }] }
```

The problem with managing the grid yourself is that there is nothing stopping you from making bad moves. For example, playing twice.

```ruby
g = Grid.new('xx')
Evaluator.analyze(g, Grid::O) # => { status: :invalid_grid, type: :too_many_moves_ahead }
```

To avoid such situations, let the engine handle game play. Once you tell it who plays first, then it ensures that the game play follows the rules of [Tic-tac-toe](http://en.wikipedia.org/wiki/Tic-tac-toe).

```ruby
e = Engine.new
e.start(Grid::O).play(2, 1).play(1, 1).play(2, 2).play(1, 2).play(2, 3)
e.last_event # => { name: :game_over, type: :winner, last_move: { turn: :o, r: 2, c: 3 },
             #      details: [{ where: :row, index: 2, positions: [[2, 1], [2, 2], [2, 3]] }] }
```

I quickly built a [Tic-tac-toe](http://en.wikipedia.org/wiki/Tic-tac-toe) client that uses the engine and all the other abstractions in this library. See how everything comes together by viewing its implementation right [here](https://github.com/dwayne/xo/blob/master/bin/xo).

**NOTE:** *I plan to rewrite the client code following the [SOLID principles](http://en.wikipedia.org/wiki/SOLID_(object-oriented_design)) so stay tuned for that.*

**TODO:**

- Release a new version, once I complete the rewrite of the client.

## Performance of the Minimax Algorithm

```ruby
require 'benchmark'
require 'xo/ai/minimax'

puts Benchmark.measure { XO::AI::Minimax.instance }
# => 3.090000   0.000000   3.090000 (  3.091686)
```

## Testing

You can run:

- All specs: `bundle exec rake`, or
- A specific spec: `bundle exec ruby -Ilib -Ispec spec/path_to_spec_file.rb`

## Contributing

If you'd like to contribute a feature or bugfix: Thanks! To make sure your fix/feature has a high chance of being included, please read the following guidelines:

1. Post a [pull request](https://github.com/dwayne/xo/compare/).
2. Make sure there are tests! I will not accept any patch that is not tested. It's a rare time when explicit tests aren't needed. If you have questions about writing tests for xo, please open a [GitHub issue](https://github.com/dwayne/xo/issues/new).

## License

xo is Copyright © 2014 Dwayne R. Crooks. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
