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
