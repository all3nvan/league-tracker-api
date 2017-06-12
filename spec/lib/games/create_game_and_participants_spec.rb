require 'rails_helper'

RSpec.describe Games::CreateGameAndParticipants do
  before do
    allow(RiotApi::Client).to receive(:new).and_return(riot_api_client)
  end

  describe '#call' do
    let(:game_id) { 123 }
    let(:create_game_and_participants) { Games::CreateGameAndParticipants.new(game_id) }
    let(:riot_api_client) { instance_double(RiotApi::ThrottledClient) }
    let(:game_create_time) { 1496381604616 / 1000 }
    let(:riot_api_participants) { create_participants }
    let(:riot_api_game) {
      RiotApi::Game.new({
        game_id: game_id,
        create_time: Time.at(game_create_time),
        participants: riot_api_participants
      })
    }

    context 'when game_id already exists' do
      it 'raises error' do
        allow(Game).to receive(:exists?).with(any_args).and_return(true)

        expect(Game).to receive(:exists?).with({ game_id: game_id })
        expect{ create_game_and_participants.call }.to raise_error(Games::DuplicateGameError)
      end
    end

    context 'when game_id is new' do
      it 'returns Game object with GameParticipant objects' do
        allow(riot_api_client).to receive(:get_game).with(any_args).and_return(riot_api_game)

        expect(riot_api_client).to receive(:get_game).with(game_id)

        game = create_game_and_participants.call

        expect(game.game_id).to eq(riot_api_game.game_id)
        expect(game.create_time).to eq(riot_api_game.create_time)
        expect(game.game_participants.count).to eq(riot_api_game.participants.count)
        game.game_participants.each_with_index do |game_participant, i|
          expect(game_participant.team).to eq(riot_api_participants[i].team)
          expect(game_participant.champion_id).to eq(riot_api_participants[i].champion_id)
          expect(game_participant.win).to eq(riot_api_participants[i].win)
          expect(game_participant.kills).to eq(riot_api_participants[i].kills)
          expect(game_participant.deaths).to eq(riot_api_participants[i].deaths)
          expect(game_participant.assists).to eq(riot_api_participants[i].assists)
        end
      end
    end
  end

  private

  def create_participants
    blue_team_participants = (1..5).map do |i|
      RiotApi::Participant.new({
        team: 'BLUE',
        win: true,
        champion_id: i,
        kills: i,
        deaths: i,
        assists: i
      })
    end
    red_team_participants = (6..10).map do |i|
      RiotApi::Participant.new({
        team: 'RED',
        win: false,
        champion_id: i,
        kills: i,
        deaths: i,
        assists: i
      })
    end
    blue_team_participants.concat(red_team_participants)
  end
end
