# TODO: This should prob be renamed since it updates/returns both participant and summoner.
class GameParticipantsController < ApplicationController
  before_action :authenticate_admin, only: :update
  before_action :validate_patch_params, only: :update

  def update
    begin
      summoner = Summoners::FindOrCreateSummoner.new(summoner_name).call
    # TODO: Have some sort of exception interceptor on the way out?
    rescue RiotApi::Errors::ClientError => e
      render status: :bad_request, json: { message: e.message } and return
    rescue RiotApi::Errors::ServerError => e
      render status: :service_unavailable, json: { message: e.message } and return
    rescue RiotApi::Errors::ThrottledError => e
      render status: :too_many_requests, json: { message: e.message } and return
    end

    # TODO: Prob will need to pass in entire object here and do optimistic locking
    # https://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html
    game_participant = GameParticipant.find(params[:id])
    game_participant.update(summoner: summoner)

    game_participant_json = ActiveModelSerializers::SerializableResource
      .new(game_participant, {})
      .as_json
    summoner_json = ActiveModelSerializers::SerializableResource
      .new(summoner, {})
      .as_json

    render json: {
      gameParticipant: game_participant_json,
      summoner: summoner_json
    }
  end

  private

  def validate_patch_params
    unless valid_patch_params?
      render(
        json: { message: 'Required object with summonerName property.' },
        status: :bad_request
      )
    end
  end

  def valid_patch_params?
    game_participant = params[:gameParticipant]
    !game_participant.nil? &&
      # TODO: is there a better way to check that this isn't an int/string?
      game_participant.is_a?(ActionController::Parameters) &&
      !summoner_name.nil?
  end

  def summoner_name
    params[:gameParticipant][:summonerName]
  end
end
