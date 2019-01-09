require 'TrueSkill'

module Ratings
  class RatingsCalculator
    def summoner_ratings
      # TODO: move these to some GameRepository class
      games = Game.includes(:game_participants).order(create_time: :asc)
      games_without_unknown_participants = games.select do |game|
        game.game_participants.all? { |participant| !participant.summoner_id.nil? }
      end

      summoner_id_to_rating = {}

      games_without_unknown_participants.each do |game|
        partitions = game.game_participants.partition(&:win)
        winning_summoner_ids = partitions[0].map(&:summoner_id)
        losing_summoner_ids = partitions[1].map(&:summoner_id)

        winner_ratings = winning_summoner_ids.map do |id|
          unless summoner_id_to_rating.key?(id)
            summoner_id_to_rating[id] = Rating.new
          end
          summoner_id_to_rating[id]
        end
        loser_ratings = losing_summoner_ids.map do |id|
          unless summoner_id_to_rating.key?(id)
            summoner_id_to_rating[id] = Rating.new
          end
          summoner_id_to_rating[id]
        end
        new_ratings = g().transform_ratings([winner_ratings, loser_ratings], [0, 1])

        new_winner_ratings = new_ratings[0]
        new_loser_ratings = new_ratings[1]

        new_winner_ratings.each_with_index do |rating, i|
          summoner_id = winning_summoner_ids[i]
          summoner_id_to_rating[summoner_id] = rating
        end

        new_loser_ratings.each_with_index do |rating, i|
          summoner_id = losing_summoner_ids[i]
          summoner_id_to_rating[summoner_id] = rating
        end
      end

      summoner_id_to_rating.reduce([]) do |arr, (id, rating)|
        summoner_rating = SummonerRating.new(
          summoner_id: id,
          rating: rating.exposure,
          wins: summoner_wins(id),
          losses: summoner_losses(id)
        )
        arr.push(summoner_rating)
      end
    end

    private

    def summoner_wins(summoner_id)
      GameParticipant.where(summoner_id: summoner_id, win: true).count
    end

    def summoner_losses(summoner_id)
      GameParticipant.where(summoner_id: summoner_id, win: false).count
    end
  end
end
