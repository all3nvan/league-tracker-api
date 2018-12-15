module Ratings
  class SummonerRating
    include ActiveModel::Serialization

    attr_reader :summoner_id, :rating

    def initialize(args)
      @summoner_id = args[:summoner_id]
      @rating = args[:rating]
    end
  end
end
