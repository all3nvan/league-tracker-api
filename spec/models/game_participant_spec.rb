require 'rails_helper'

RSpec.describe GameParticipant, type: :model do
  context 'required fields missing' do
    let(:game_participant) { GameParticipant.new }

    it 'requires game' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :game
    end

    it 'requires team' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :team
    end

    it 'requires champion_id' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :champion_id
    end

    it 'requires win' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :win
    end

    it 'requires kills' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :kills
    end

    it 'requires deaths' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :deaths
    end

    it 'requires assists' do
      expect(game_participant).to_not be_valid
      expect(game_participant.errors.keys).to include :assists
    end
  end

  context 'valid game_participant' do
    it 'has all required fields' do
      game = Game.new(create_time: DateTime.now, game_id: 123)
      game_participant = GameParticipant.new(
        game: game,
        team: 'BLUE',
        champion_id: 1,
        win: true,
        kills: 5,
        deaths: 0,
        assists: 10
      )

      expect(game_participant).to be_valid
    end
  end
end
