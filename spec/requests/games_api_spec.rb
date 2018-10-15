require 'rails_helper'

RSpec.describe 'Games API', type: :request do
  let(:admin) { Admin.create(username: 'admin', password: '1') }
  let(:token) { Knock::AuthToken.new(payload: { sub: admin.id }).token }
  let(:headers) {
    {
      'CONTENT_TYPE': 'application/json',
      'Authorization': "Bearer #{token}"
    }
  }

  before do
    WebMock.allow_net_connect!
  end

  context 'when successful POST' do
    it 'returns the game and its participants as JSON' do
      post '/games', params: '{ "gameId": 2513935315 }', headers: headers

      response_json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      game_json = response_json['game']
      # TODO: Prob should have a test on the Serializer for these instead.
      expect(game_json['gameId']).to eq(2513935315)
      expect(game_json['createTime']).to eq('2017-06-02T05:33:24.000Z')
      expect(game_json['gameParticipantIds'].length).to eq(10)

      game_participants_json = response_json['gameParticipants']
      expect(game_participants_json.length).to eq(10)
      game_participants_json.each do |participant_json|
        expect(participant_json['gameId']).to eq(2513935315)
        expect(participant_json['championId']).to_not be_nil
        expect(participant_json['id']).to_not be_nil
        expect(participant_json['team']).to_not be_nil
        expect(participant_json['kills']).to_not be_nil
        expect(participant_json['deaths']).to_not be_nil
        expect(participant_json['assists']).to_not be_nil
        expect(participant_json['win']).to_not be_nil
      end
    end
  end
end
