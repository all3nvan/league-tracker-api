require 'saulabs/trueskill'

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
            summoner_id_to_rating[id] = Saulabs::TrueSkill::Rating.new(25, 8.333)
          end
          summoner_id_to_rating[id]
        end
        loser_ratings = losing_summoner_ids.map do |id|
          unless summoner_id_to_rating.key?(id)
            summoner_id_to_rating[id] = Saulabs::TrueSkill::Rating.new(25, 8.333)
          end
          summoner_id_to_rating[id]
        end
        graph = Saulabs::TrueSkill::FactorGraph.new([winner_ratings, loser_ratings], [1, 2])
        graph.update_skills

        new_winner_ratings = graph.teams[0]
        new_loser_ratings = graph.teams[1]

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
        summoner_rating = SummonerRating.new(summoner_id: id, rating: rating.mean - (3 * rating.deviation))
        arr.push(summoner_rating)
      end
    end
  end
end
