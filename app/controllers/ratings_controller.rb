class RatingsController < ApplicationController
  def index
    summoner_ratings = Ratings::RatingsCalculator.new.summoner_ratings
    sorted_summoner_ratings = summoner_ratings.sort { |a, b| b.rating <=> a.rating }
    render json: {
      ratings: ActiveModelSerializers::SerializableResource.new(sorted_summoner_ratings, {}).as_json
    }
  end
end
