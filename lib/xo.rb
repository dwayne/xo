module XO

  X = :x
  O = :o

  def self.is_token?(val)
    [X, O].include?(val)
  end

  def self.other_token(token)
    token == X ? O : (token == O ? X : token)
  end

  class << self
    alias_method :other_player, :other_token
  end

  class Position < Struct.new(:row, :column); end
end

require 'xo/grid'
require 'xo/evaluator'
require 'xo/engine'
require 'xo/ai'
