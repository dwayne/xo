module XO

  module AI

    class Player

      attr_reader :token

      def initialize(token)
        @token = token
      end

      def terminal_score(outcome)
        send("#{outcome}_value")
      end

      def non_terminal_score(next_grids, scores)
        best_score(compute_next_grids_scores(next_grids, scores))
      end

      def best_score(next_grids_scores)
        raise NotImplementedError
      end

      def winner_value
        raise NotImplementedError
      end

      def loser_value
        raise NotImplementedError
      end

      def squashed_value
        0
      end

      private

        def compute_next_grids_scores(next_grids, scores)
          next_grids.map { |grid| scores[grid] }
        end
    end
  end
end
