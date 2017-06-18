require 'rails_helper'

RSpec.describe Summoners::FindOrCreateSummoner do
  before do
    allow(RiotApi::ThrottledClient).to receive(:new).and_return(riot_api_client)
  end

  describe '#call' do
    let(:find_or_create_summoner) { Summoners::FindOrCreateSummoner.new(summoner_name) }
    let(:summoner_name) { 'all3nvan' }
    let(:summoner_id) { 123 }
    let(:riot_api_client) { instance_double(RiotApi::ThrottledClient) }

    context 'when summoner name already exists' do
      it 'returns the summoner' do
        summoner = Summoner.create(summoner_id: summoner_id, name: summoner_name)

        expect(find_or_create_summoner.call).to eq(summoner)
      end
    end

    context 'when summoner name does not exist' do
      let(:riot_api_summoner) {
        RiotApi::Summoner.new({
          summoner_id: summoner_id,
          name: summoner_name
        })
      }

      before do
        allow(riot_api_client)
          .to receive(:get_summoner)
          .with(any_args)
          .and_return(riot_api_summoner)
      end

      context 'when summoner is found by Riot API' do
        it 'creates summoner and returns it' do
          expect(riot_api_client).to receive(:get_summoner).with(summoner_name)

          summoner = find_or_create_summoner.call

          expect(summoner).to eq(Summoner.find(summoner_id))
        end
      end

      context 'when summoner id found by Riot API already exists in database' do
        it 'updates summoner to new name' do
          Summoner.create(summoner_id: summoner_id, name: 'old name')

          expect(riot_api_client).to receive(:get_summoner).with(summoner_name)

          expected_summoner = find_or_create_summoner.call
          actual_summoner = Summoner.find(summoner_id)

          expect(actual_summoner.name).to eq(expected_summoner.name)
          expect(actual_summoner.summoner_id).to eq(expected_summoner.summoner_id)
        end
      end
    end
  end
end
