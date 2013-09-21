module TTT

  X = :x
  O = :o

  def self.is_token?(val)
    [X, O].include?(val)
  end
end

require 'xo/grid'
require 'xo/evaluator'
require 'xo/engine'
