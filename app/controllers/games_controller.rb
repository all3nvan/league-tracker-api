# TODO: This might need to be renamed since it creates and returns both game and participants
class GamesController < ApplicationController
  before_action :authenticate_admin, only: :create
  before_action :validate_post_params, only: :create

  def create
    begin
      game = Games::CreateGameAndParticipants.new(params[:gameId]).call
    # TODO: Have some sort of exception interceptor on the way out?
    rescue Games::DuplicateGameError  => e
      render status: :conflict, json: { message: e.message } and return
    rescue RiotApi::Errors::ClientError => e
      render status: :bad_request, json: { message: e.message } and return
    rescue RiotApi::Errors::ServerError  => e
      render status: :service_unavailable, json: { message: e.message } and return
    rescue RiotApi::Errors::ThrottledError  => e
      render status: :too_many_requests, json: { message: e.message } and return
    end

    game_json = ActiveModelSerializers::SerializableResource.new(game, {}).as_json

    render json: {
      game: game_json,
      gameParticipants: ActiveModelSerializers::SerializableResource.new(game.game_participants, {}).as_json
    }
  end

  private

  def validate_post_params
    game_id = params[:gameId]

    if game_id.nil? || !game_id.is_a?(Integer)
      render json: { message: 'Game id required and must be numeric.' }, status: :bad_request
    end
  end
end
