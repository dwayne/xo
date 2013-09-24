# xo

A [Ruby](http://www.ruby-lang.org/en/) library for [Tic-tac-toe](http://en.wikipedia.org/wiki/Tic-tac-toe).

# Running the Tests

You can run:

- All tests: `rake test`
- One test: `ruby -Ilib -Ispec spec/path_to_spec_file.rb`

# Performance of the Minimax Algorithm

```ruby
require 'benchmark'
require 'xo'
require 'xo/ai_zero'

# Empty grid
g = TTT::Grid.new

puts Benchmark.measure { TTT::AI::Zero.minimax(g, :x) }
# => 141.860000   0.530000 142.390000 (142.706254)

puts Benchmark.measure { TTT::AI.minimax(g, :x) }
# =>  25.920000   0.040000  25.960000 ( 26.015781)

# One spot taken
g = TTT::Grid.new
g[1, 1] = :x

puts Benchmark.measure { TTT::AI::Zero.minimax(g, :o) }
# => 29.720000   0.030000  29.750000 ( 29.814392)

puts Benchmark.measure { TTT::AI.minimax(g, :o) }
# => 20.500000   0.000000  20.500000 ( 20.549392)

g.clear
g[1, 2] = :x

puts Benchmark.measure { TTT::AI::Zero.minimax(g, :o) }
# => 32.110000   0.000000  32.110000 ( 32.183889)

puts Benchmark.measure { TTT::AI.minimax(g, :o) }
# => 19.270000   0.000000  19.270000 ( 19.313670)

g.clear
g[2, 2] = :x

puts Benchmark.measure { TTT::AI::Zero.minimax(g, :o) }
# => 28.720000   0.000000  28.720000 ( 28.787924)

puts Benchmark.measure { TTT::AI.minimax(g, :o) }
# => 3.020000   0.020000   3.040000 (  3.037931)
```
