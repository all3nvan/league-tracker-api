require 'rails_helper'

RSpec.describe 'GameParticipants API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  before do
    WebMock.allow_net_connect!
  end

  context 'when successful PATCH' do
    it 'returns the game participant with updated summoner id as JSON' do
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

      game_participant_json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(game_participant_json['gameParticipant']['summonerId']).to eq(23472148)
    end
  end
end
