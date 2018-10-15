require 'rails_helper'

RSpec.describe GameParticipantsController, type: :controller do
  let(:find_or_create_summoner) { instance_double(Summoners::FindOrCreateSummoner) }
  let(:admin) { Admin.create(username: 'admin', password: '1') }
  let(:token) { Knock::AuthToken.new(payload: { sub: admin.id }).token }

  before do
    request.headers['Content-Type'] = 'application/json'
    request.headers['Authorization'] = "Bearer #{token}"

    allow(Summoners::FindOrCreateSummoner)
      .to receive(:new)
      .with(any_args)
      .and_return(find_or_create_summoner)
  end

  describe '#update' do
    context 'when unauthenticated' do
      it 'is a 401' do
        request.headers['Authorization'] = ''

        patch :update, params: { id: 123 }

        expect(response.status).to eq(401)
      end
    end

    describe 'params' do
      context 'when gameParticipant is missing' do
        it 'is a 400' do
          patch :update, params: { id: 123 }

          expect(response.status).to eq(400)
        end
      end

      context 'when gameParticipant is missing summonerName' do
        it 'is a 400' do
          patch :update, params: { id: 123, gameParticipant: 'asdf' }

          expect(response.status).to eq(400)
        end
      end
    end

    context 'when valid summonerName is passed in' do
      it 'links game participant to associated summoner' do
        summoner_id = 111
        summoner_name = 'asdf'
        summoner = Summoner.new(summoner_id: summoner_id, name: summoner_name)
        game_participant = GameParticipant.create(
          team: 'BLUE',
          champion_id: 1,
          kills: 1,
          deaths: 1,
          assists: 1,
          win: true,
          game: Game.create(create_time: Time.now, game_id: 123)
        )

        allow(find_or_create_summoner).to receive(:call).and_return(summoner)

        expect(Summoners::FindOrCreateSummoner).to receive(:new).with(summoner_name)
        expect(find_or_create_summoner).to receive(:call)

        patch(
          :update,
          params: {
            id: game_participant.id,
            gameParticipant: {
              summonerName: summoner_name
            }
          }
        )

        game_participant.reload
        game_participant_json = ActiveModelSerializers::SerializableResource
          .new(game_participant, {})
          .as_json
        summoner_json = ActiveModelSerializers::SerializableResource
          .new(summoner, {})
          .as_json

        expect(game_participant.summoner).to eq(summoner)
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq({
          gameParticipant: game_participant_json,
          summoner: summoner_json
        }.as_json)
      end
    end

    context 'when FindOrCreateSummoner raises error' do
      it 'is a 400 for client error' do
        allow(find_or_create_summoner)
          .to receive(:call)
          .and_raise(RiotApi::Errors::ClientError)

        patch :update, params: { id: 1, gameParticipant: { summonerName: 'asdf' } }

        expect(response.status).to eq(400)
      end

      it 'is a 429 for throttled error' do
        allow(find_or_create_summoner)
          .to receive(:call)
          .and_raise(RiotApi::Errors::ThrottledError)

        patch :update, params: { id: 1, gameParticipant: { summonerName: 'asdf' } }

        expect(response.status).to eq(429)
      end

      it 'is a 503 for server error' do
        allow(find_or_create_summoner)
          .to receive(:call)
          .and_raise(RiotApi::Errors::ServerError)

        patch :update, params: { id: 1, gameParticipant: { summonerName: 'asdf' } }

        expect(response.status).to eq(503)
      end
    end
  end
end
