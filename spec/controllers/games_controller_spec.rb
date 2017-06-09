require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  before do
    request.headers['Content-Type'] = 'application/json'
  end

  describe '#create' do
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
      let(:create_game_and_participants) { instance_double(Games::CreateGameAndParticipants) }
      let(:game_id) { 123 }

      before do
        allow(Games::CreateGameAndParticipants)
          .to receive(:new)
          .with(any_args)
          .and_return(create_game_and_participants)
      end

      context 'when gameId is new' do
        it 'calls CreateGameAndParticipants and returns game and participant objects' do
          game = Game.new(create_time: DateTime.now, game_id: game_id)
          (1..10).each do |i|
            game.game_participants.new(summoner_id: i, kills: i, deaths: i, assists: i)
          end
          game_json = ActiveModelSerializers::SerializableResource.new(game, {}).to_json

          allow(create_game_and_participants).to receive(:call).and_return(game)

          expect(Games::CreateGameAndParticipants).to receive(:new).with(game_id)
          expect(create_game_and_participants).to receive(:call)

          post :create, params: { gameId: game_id }

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to eq({ 'game' => game_json })
        end
      end

      context 'when gameId already exists' do
        it' is a 409' do
          allow(create_game_and_participants).to receive(:call).and_raise(Games::DuplicateGameError)

          expect(Games::CreateGameAndParticipants).to receive(:new).with(game_id)
          expect(create_game_and_participants).to receive(:call)

          post :create, params: { gameId: game_id }

          expect(response.status).to eq(409)
        end
      end
    end
  end
end
