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
      all_participants = blue_participants + red_participants
      all_participant_ids = all_participants.map(&:id)

      summoner = Summoner.create(summoner_id: 23472148, name: 'all3nvan')

      get("/single_page_app_initializations")

      response_json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      # Game object
      game_json = response_json['games'][game.game_id.to_s]
      expect(game_json['gameId']).to eq(game.game_id)
      game_participant_ids_json = game_json['gameParticipantIds']
      expect(game_participant_ids_json).to match_array(all_participant_ids)

      # Game participants object
      game_participants_json = response_json['gameParticipants']
      expect(game_participants_json.size).to eq(all_participants.size)
      all_participants.each do |participant|
        expect(game_participants_json[participant.id]['id']).to eq(participant.id)
        expect(game_participants_json[participant.id]['gameId']).to eq(participant.game_id)
        expect(game_participants_json[participant.id]['summonerId']).to eq(participant.summoner_id)
        expect(game_participants_json[participant.id]['championId']).to eq(participant.champion_id)
        expect(game_participants_json[participant.id]['team']).to eq(participant.team)
        expect(game_participants_json[participant.id]['kills']).to eq(participant.kills)
        expect(game_participants_json[participant.id]['deaths']).to eq(participant.deaths)
        expect(game_participants_json[participant.id]['assists']).to eq(participant.assists)
        expect(game_participants_json[participant.id]['win']).to eq(participant.win)
      end

      # Summoners object
      summoner_json = response_json['summoners'][summoner.summoner_id.to_s]
      expect(summoner_json['summonerId']).to eq(summoner.summoner_id)
      expect(summoner_json['name']).to eq(summoner.name)
    end
  end
end
