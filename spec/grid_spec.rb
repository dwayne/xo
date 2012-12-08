require 'spec_helper'

def for_each_cell
  [1, 2, 3].each { |r| [1, 2, 3].each { |c| yield r, c } }
end

describe TicTacToe::Grid do

  describe "it's dimensions" do
    it "must have 3 rows" do
      TicTacToe::Grid::ROWS.must_equal 3
    end

    it "must have 3 columns" do
      TicTacToe::Grid::COLS.must_equal 3
    end
  end

  describe "it's layout" do
    #     1   2   3
    # 1     |   |
    #    ---+---+---
    # 2     |   |
    #    ---+---+---
    # 3     |   |
    it "must contain the cells for which the row and column values are both in [1..3]" do
      for_each_cell { |r, c| TicTacToe::Grid.contains?(r, c).must_equal true }
    end

    it "must not contain any cells for which either the row or column value is not in [1..3]" do
      # unfortunately this requirement cannot be tested completely
      # however, the tests below should be sufficient to ensure
      # that an implementation doesn't have off by one errors
      [0, 1, 2, 3, 4].each { |r| TicTacToe::Grid.contains?(r, 0).must_equal false }
      [0, 1, 2, 3, 4].each { |r| TicTacToe::Grid.contains?(r, 4).must_equal false }
      [0, 1, 2, 3, 4].each { |c| TicTacToe::Grid.contains?(0, c).must_equal false }
      [0, 1, 2, 3, 4].each { |c| TicTacToe::Grid.contains?(4, c).must_equal false }
    end
  end

  describe "how it works" do
    before do
      @grid = TicTacToe::Grid.new
    end

    it "initializes each cell to the empty token" do
      for_each_cell { |r, c| @grid.empty?(r, c).must_equal true }
    end

    it "returns the same token it put into the cell" do
      for_each_cell do |r, c|
        @grid.putx(r, c)[r, c].must_equal :x
        @grid.puto(r, c)[r, c].must_equal :o
      end
    end

    it "fails with an IndexError exception whenever an out of bounds cell is accessed" do
      lambda { @grid[0, 0] }.must_raise IndexError
    end

    it "can clear individual cells" do
      for_each_cell do |r, c|
        @grid.putx(r, c).clear(r, c).empty?(r, c).must_equal true
        @grid.puto(r, c).clear(r, c).empty?(r, c).must_equal true
      end
    end

    it "can clear all cells at once" do
      # fill the cells with x's and o's
      for_each_cell { |r, c| @grid.putx(r, c) }
      @grid.puto 1, 1
      @grid.puto 1, 3
      @grid.puto 3, 1
      @grid.puto 3, 3

      @grid.clear_all

      for_each_cell { |r, c| @grid.empty?(r, c).must_equal true }
    end

    it "is cloneable" do
      @grid.putx 1, 1
      @grid.puto 1, 2

      grid_clone = @grid.clone
      grid_clone.clear_all

      @grid[1, 1].must_equal :x
      @grid[1, 2].must_equal :o

      grid_clone.putx 1, 3

      @grid.empty?(1, 3).must_equal true
    end

    describe "how status works" do

      describe ":game_in_progress" do
        it "returns :game_in_progress for an empty grid" do
          @grid.xstatus.must_be :==, { kind: :ok, type: :game_in_progress }
          @grid.ostatus.must_be :==, { kind: :ok, type: :game_in_progress }
        end

        it "returns :game_in_progress for an equal amount of both tokens in a non-winning position" do
          @grid.putx(1, 1).putx(1, 2).puto(2, 1).puto(2, 2)
          @grid.xstatus.must_be :==, { kind: :ok, type: :game_in_progress }
          @grid.ostatus.must_be :==, { kind: :ok, type: :game_in_progress }
        end

        it "returns :game_in_progress whenever the token count is ahead by one for any of the tokens" do
          @grid.putx(1, 1).puto(2, 2).putx(3, 3)
          @grid.xstatus.must_be :==, { kind: :ok, type: :game_in_progress }

          @grid.clear_all.puto(1, 3).putx(2, 2).puto(3, 1)
          @grid.ostatus.must_be :==, { kind: :ok, type: :game_in_progress }
        end
      end

      describe ":game_over" do
        it "is a squashed game whenever all the cells are filled and their is no winner" do
          @grid.putx(1, 1).puto(2, 2).putx(3, 3).puto(2, 1).putx(2, 3).puto(1, 3).putx(3, 1).puto(3, 2).putx(1, 2)
          @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :squashed }
        end

        describe "winning positions" do
          it "is a win in the first row" do
            @grid.putx(1, 1).puto(2, 1).putx(1, 2).puto(2, 2).putx(1, 3)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ row: 1 }] }

            @grid.clear_all.puto(1, 1).putx(2, 1).puto(1, 2).putx(2, 2).puto(1, 3)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ row: 1 }] }
          end

          it "is a win in the second row" do
            @grid.putx(2, 1).puto(1, 1).putx(2, 2).puto(1, 2).putx(2, 3)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ row: 2 }] }

            @grid.clear_all.puto(2, 1).putx(1, 1).puto(2, 2).putx(1, 2).puto(2, 3)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ row: 2 }] }
          end

          it "is a win in the third row" do
            @grid.putx(3, 1).puto(2, 1).putx(3, 2).puto(2, 2).putx(3, 3)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ row: 3 }] }

            @grid.clear_all.puto(3, 1).putx(2, 1).puto(3, 2).putx(2, 2).puto(3, 3)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ row: 3 }] }
          end

          it "is a win in the first column" do
            @grid.putx(1, 1).puto(1, 2).putx(2, 1).puto(2, 2).putx(3, 1)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ col: 1 }] }

            @grid.clear_all.puto(1, 1).putx(1, 2).puto(2, 1).putx(2, 2).puto(3, 1)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ col: 1 }] }
          end

          it "is a win in the second column" do
            @grid.putx(1, 2).puto(1, 1).putx(2, 2).puto(2, 1).putx(3, 2)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ col: 2 }] }

            @grid.clear_all.puto(1, 2).putx(1, 1).puto(2, 2).putx(2, 1).puto(3, 2)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ col: 2 }] }
          end

          it "is a win in the third column" do
            @grid.putx(1, 3).puto(2, 1).putx(2, 3).puto(2, 2).putx(3, 3)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ col: 3 }] }

            @grid.clear_all.puto(1, 3).putx(2, 1).puto(2, 3).putx(2, 2).puto(3, 3)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ col: 3 }] }
          end

          it "is a win in the first diagonal" do
            @grid.putx(1, 1).puto(1, 2).putx(2, 2).puto(2, 1).putx(3, 3)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ diag: 1 }] }

            @grid.clear_all.puto(1, 1).putx(1, 2).puto(2, 2).putx(2, 1).puto(3, 3)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ diag: 1 }] }
          end

          it "is a win in the second diagonal" do
            @grid.putx(1, 3).puto(2, 1).putx(2, 2).puto(2, 3).putx(3, 1)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ diag: 2 }] }

            @grid.clear_all.puto(1, 3).putx(2, 1).puto(2, 2).putx(2, 3).puto(3, 1)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ diag: 2 }] }
          end

          it "is a win in both diagonals" do
            @grid.putx(1, 1).puto(1, 2).putx(1, 3).puto(2, 1).putx(2, 2).puto(2, 3).putx(3, 1).puto(3, 2).putx(3, 3)
            @grid.xstatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ diag: 1 }, { diag: 2 }]}

            @grid.puto(1, 1).putx(1, 2).puto(1, 3).putx(2, 1).puto(2, 2).putx(2, 3).puto(3, 1).putx(3, 2).puto(3, 3)
            @grid.ostatus.must_be :==, { kind: :ok, type: :game_over, reason: :win, details: [{ diag: 1 }, { diag: 2 }]}
          end

          # TODO: Test double wins in row r and column c
        end
      end

      describe "error conditions" do
        it "returns :did_not_make_last_move when the token used to get the status could not have been the last to be placed on the grid" do
          @grid.putx 1, 1
          @grid.ostatus.must_be :==, { kind: :error, type: :did_not_make_last_move }
        end

        it "returns :illegal_configuration whenever the token count is ahead by two or more for any of the tokens" do
          @grid.putx(1, 1).putx(2, 3)
          @grid.xstatus.must_be :==, { kind: :error, type: :illegal_configuration }
          @grid.ostatus.must_be :==, { kind: :error, type: :illegal_configuration }

          @grid.puto(3, 1).puto(3, 2).puto(3, 3).puto(2, 2)
          @grid.xstatus.must_be :==, { kind: :error, type: :illegal_configuration }
          @grid.ostatus.must_be :==, { kind: :error, type: :illegal_configuration }
        end
      end
    end
  end
end
