class GamesController < ApplicationController
  before_action :validate_post_params, only: :create

  def create
    begin
      game = Games::CreateGameAndParticipants.new(params[:gameId]).call
    rescue Games::DuplicateGameError
      render status: :conflict and return
    end

    game_json = ActiveModelSerializers::SerializableResource.new(game, {}).as_json

    render json: { game: game_json }
  end

  private

  def validate_post_params
    game_id = params[:gameId]

    if game_id.nil? || !game_id.is_a?(Integer)
      render json: { error: { gameId: 'Required and must be numeric.' } }, status: :bad_request
    end
  end
end
