require 'rails_helper'

RSpec.describe Game, type: :model do
  context 'required fields missing' do
    let(:game) { Game.new }

    it 'requires create_time' do
      expect(game).to_not be_valid
      expect(game.errors.keys).to include :create_time
    end

    it 'requires game_id' do
      expect(game).to_not be_valid
      expect(game.errors.keys).to include :game_id
    end
  end

  context 'valid game' do
    it 'has all required fields' do
      game = Game.new(create_time: DateTime.now, game_id: 1)

      expect(game).to be_valid
    end
  end

  describe 'game_id' do
    it 'is unique' do
      Game.create(create_time: DateTime.now, game_id: 1)
      game_with_duplicate_game_id = Game.new(create_time: DateTime.now, game_id: 1)

      expect(game_with_duplicate_game_id).to_not be_valid
      expect(game_with_duplicate_game_id.errors.keys).to include :game_id
    end
  end
end
