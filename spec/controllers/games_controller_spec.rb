require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:create_game_and_participants) { instance_double(Games::CreateGameAndParticipants) }
  let(:game_id) { 123 }
  let(:admin) { Admin.create(username: 'admin', password: '1') }
  let(:token) { Knock::AuthToken.new(payload: { sub: admin.id }).token }

  before do
    request.headers['Content-Type'] = 'application/json'
    request.headers['Authorization'] = "Bearer #{token}"

    allow(Games::CreateGameAndParticipants)
      .to receive(:new)
      .with(any_args)
      .and_return(create_game_and_participants)
  end

  describe '#create' do
    context 'when unauthenticated' do
      it 'is a 401' do
        request.headers['Authorization'] = ''

        post :create

        expect(response.status).to eq(401)
      end
    end

    context 'when gameId is missing' do
      it 'is a 400' do
        post :create
        expect(response.status).to eq(400)
      end
    end

    context 'when gameId is not numeric' do
      it 'is a 400' do
        post :create, params: { gameId: 'asdf' }
        expect(response.status).to eq(400)
      end
    end

    context 'when valid gameId is passed in' do
      context 'when gameId is new' do
        it 'calls CreateGameAndParticipants and returns game and participant objects' do
          game = Game.new(create_time: DateTime.now, game_id: game_id)
          (1..10).each do |i|
            game.game_participants.new(summoner_id: i, kills: i, deaths: i, assists: i)
          end
          game_json = ActiveModelSerializers::SerializableResource.new(game, {}).as_json

          allow(create_game_and_participants).to receive(:call).and_return(game)

          expect(Games::CreateGameAndParticipants).to receive(:new).with(game_id)
          expect(create_game_and_participants).to receive(:call)

          post :create, params: { gameId: game_id }

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to eq({ game: game_json }.as_json)
        end
      end

      context 'when gameId already exists' do
        it' is a 409' do
          allow(create_game_and_participants)
            .to receive(:call)
            .and_raise(Games::DuplicateGameError)

          expect(Games::CreateGameAndParticipants).to receive(:new).with(game_id)
          expect(create_game_and_participants).to receive(:call)

          post :create, params: { gameId: game_id }

          expect(response.status).to eq(409)
        end
      end
    end

    context 'when CreateGameAndParticipants raises error' do
      it 'is a 400 for client error' do
        allow(create_game_and_participants)
          .to receive(:call)
          .and_raise(RiotApi::Errors::ClientError)

        post :create, params: { gameId: game_id }

        expect(response.status).to eq(400)
      end

      it 'is a 429 for throttled error' do
        allow(create_game_and_participants)
          .to receive(:call)
          .and_raise(RiotApi::Errors::ThrottledError)

        post :create, params: { gameId: game_id }

        expect(response.status).to eq(429)
      end

      it 'is a 503 for server error' do
        allow(create_game_and_participants)
          .to receive(:call)
          .and_raise(RiotApi::Errors::ServerError)

        post :create, params: { gameId: game_id }

        expect(response.status).to eq(503)
      end
    end
  end
end
