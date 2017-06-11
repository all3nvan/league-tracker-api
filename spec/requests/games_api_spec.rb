require 'rails_helper'

RSpec.describe 'Games API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  before do
    WebMock.allow_net_connect!
  end

  context 'when successful POST' do
    it 'returns the game as JSON' do
      post '/games', params: '{ "gameId": 2513935315 }', headers: headers

      game_json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(game_json['game']['gameId']).to eq(2513935315)
      expect(game_json['game']['gameParticipants'].length).to eq(10)
      game_json['game']['gameParticipants'].each do |game_participant|
        expect(game_participant['championId']).to_not be_nil
        expect(game_participant['team']).to_not be_nil
        expect(game_participant['kills']).to_not be_nil
        expect(game_participant['deaths']).to_not be_nil
        expect(game_participant['assists']).to_not be_nil
        expect(game_participant['win']).to_not be_nil
      end
    end
  end
end
