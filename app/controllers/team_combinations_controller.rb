class TeamCombinationsController < ApplicationController
  before_action :validate_create_params, only: :create

  def create
    summoner_id_to_ratings = Ratings::RatingsCalculator.new.summoner_id_to_ratings

    team_1_combos = summoner_ids.combination(5).to_a
    team_2_combos = team_1_combos.map do |team_1_ids|
      summoner_ids.reject { |id| team_1_ids.include?(id) }
    end
    team_combinations = team_1_combos.each_with_index.map do |team_1_combo, i|
      team_2_combo = team_2_combos[i]

      team_1_ratings = team_1_combo.map { |id| summoner_id_to_ratings[id] }
      team_2_ratings = team_2_combo.map { |id| summoner_id_to_ratings[id] }
      match_quality = g().match_quality([team_1_ratings, team_2_ratings])
      # TODO: use win probability to determine blue/red teams
      TeamCombination.new(team_1_combo, team_2_combo, match_quality)
    end

    best_team_combos = team_combinations
      .sort_by { |team_combo| team_combo.match_quality }
      .reverse
      .first(20)

    render json: {
      teamCombinations: ActiveModelSerializers::SerializableResource.new(best_team_combos, {}).as_json
    }
  end

  private

  def validate_create_params
    unless valid_create_params?
      render json: { message: '10 valid summoner ids required.' }, status: :bad_request
    end
  end

  def valid_create_params?
    summoner_ids.size == 10 && summoner_ids.all? { |id| Summoner.exists?(id) }
  end

  def summoner_ids
    @summoner_ids ||= params[:summonerIds].map(&:to_i)
  end
end

class TeamCombination
  include ActiveModel::Serialization

  attr_reader :blue_team_summoner_ids, :red_team_summoner_ids, :match_quality

  def initialize(blue_team_summoner_ids, red_team_summoner_ids, match_quality)
    @blue_team_summoner_ids = blue_team_summoner_ids
    @red_team_summoner_ids = red_team_summoner_ids
    @match_quality = match_quality
  end
end
