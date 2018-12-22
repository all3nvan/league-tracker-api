module Ratings
  class SummonerRating
    include ActiveModel::Serialization

    attr_reader :summoner_id, :rating, :wins, :losses

    def initialize(args)
      @summoner_id = args[:summoner_id]
      @rating = args[:rating]
      @wins = args[:wins]
      @losses = args[:losses]
    end
  end
end
