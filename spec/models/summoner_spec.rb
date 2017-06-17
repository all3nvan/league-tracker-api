require 'rails_helper'

RSpec.describe Summoner, type: :model do
  describe '.summoner_id' do
    it 'is required' do
      summoner = Summoner.new

      expect(summoner).to_not be_valid
      expect(summoner.errors.keys).to include :summoner_id
    end

    it 'is unique' do
      Summoner.create(summoner_id: 1, name: 'asdf')
      summoner_with_duplicate_id = Summoner.new(summoner_id: 1, name: 'asdf')

      expect(summoner_with_duplicate_id).to_not be_valid
      expect(summoner_with_duplicate_id.errors.keys).to include :summoner_id
    end
  end

  describe '.name' do
    it 'is required' do
      summoner = Summoner.new

      expect(summoner).to_not be_valid
      expect(summoner.errors.keys).to include :name
    end
  end
end
