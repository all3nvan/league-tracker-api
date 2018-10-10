class SinglePageAppInitializationsController < ApplicationController
  def all_normalized_data
    games = Game.includes(:game_participants).all
    game_id_to_game_json_hash = games.each_with_object({}) do |game, hash|
      hash[game.game_id] = ActiveModelSerializers::SerializableResource.new(game, {}).as_json
    end

    render json: { games: game_id_to_game_json_hash }
  end
end
