class SinglePageAppInitializationsController < ApplicationController
  def all_normalized_data
    games = Game.includes(:game_participants).all
    game_id_to_json_hash = games.each_with_object({}) do |game, hash|
      hash[game.game_id] = ActiveModelSerializers::SerializableResource.new(game, {}).as_json
    end

    game_participants = GameParticipant.all
    game_participant_id_to_json_hash = game_participants.each_with_object({}) do |game_participant, hash|
      hash[game_participant.id] = ActiveModelSerializers::SerializableResource.new(game_participant, {}).as_json
    end

    render json: {
      games: game_id_to_json_hash,
      gameParticipants: game_participant_id_to_json_hash
    }
  end
end
