require 'rails_helper'

RSpec.describe 'Single Page App Initializations API', type: :request do
  context 'when successful GET' do
    it 'returns all games with game participants' do
      game = Game.create(create_time: Time.now, game_id: 123)
      blue_participants = (1..5).map do |i|
        GameParticipant.create(
          team: 'BLUE',
          champion_id: i,
          kills: i,
          deaths: i,
          assists: i,
          win: false,
          game: game
        )
      end
      red_participants = (6..10).map do |i|
        GameParticipant.create(
          team: 'RED',
          champion_id: i,
          kills: i,
          deaths: i,
          assists: i,
          win: true,
          game: game
        )
      end

      get("/single_page_app_initializations")

      response_json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      game_json = response_json['games'][game.game_id.to_s]
      expect(game_json['gameId']).to eq(game.game_id)

      game_participants_json = game_json['gameParticipants']
      blue_participants_json = game_participants_json[0..4]
      red_participants_json = game_participants_json[5..9]
      (0..4).each do |i|
        expect(blue_participants_json[i]['summonerId']).to eq(blue_participants[i].summoner_id)
        expect(blue_participants_json[i]['championId']).to eq(blue_participants[i].champion_id)
        expect(blue_participants_json[i]['id']).to eq(blue_participants[i].id)
        expect(blue_participants_json[i]['team']).to eq(blue_participants[i].team)
        expect(blue_participants_json[i]['kills']).to eq(blue_participants[i].kills)
        expect(blue_participants_json[i]['deaths']).to eq(blue_participants[i].deaths)
        expect(blue_participants_json[i]['assists']).to eq(blue_participants[i].assists)
        expect(blue_participants_json[i]['win']).to eq(blue_participants[i].win)
      end
      (0..4).each do |i|
        expect(red_participants_json[i]['summonerId']).to eq(red_participants[i].summoner_id)
        expect(red_participants_json[i]['championId']).to eq(red_participants[i].champion_id)
        expect(red_participants_json[i]['id']).to eq(red_participants[i].id)
        expect(red_participants_json[i]['team']).to eq(red_participants[i].team)
        expect(red_participants_json[i]['kills']).to eq(red_participants[i].kills)
        expect(red_participants_json[i]['deaths']).to eq(red_participants[i].deaths)
        expect(red_participants_json[i]['assists']).to eq(red_participants[i].assists)
        expect(red_participants_json[i]['win']).to eq(red_participants[i].win)
      end
    end
  end
end
