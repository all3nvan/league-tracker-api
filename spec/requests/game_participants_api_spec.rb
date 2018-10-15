require 'rails_helper'

RSpec.describe 'GameParticipants API', type: :request do
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

  context 'when successful PATCH' do
    it 'returns the game participant with updated summoner id and the summoner object as JSON' do
      game_participant = GameParticipant.create(
        team: 'BLUE',
        champion_id: 1,
        kills: 1,
        deaths: 1,
        assists: 1,
        win: true,
        game: Game.create(create_time: Time.now, game_id: 123)
      )
      params = {
        gameParticipant: {
          summonerName: 'all3nvan'
        }
      }

      patch(
        "/game_participants/#{game_participant.id}",
        params: params.to_json,
        headers: headers
      )

      response_json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(response_json['gameParticipant']['summonerId']).to eq(23472148)
      expect(response_json['summoner']['summonerId']).to eq(23472148)
      expect(response_json['summoner']['name']).to eq('all3nvan')
    end
  end
end
