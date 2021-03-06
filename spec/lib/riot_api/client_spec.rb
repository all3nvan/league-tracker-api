require 'rails_helper'

RSpec.describe RiotApi::Client do
  let(:client) { RiotApi::Client.new }

  before do
    WebMock.disable_net_connect!
  end

  describe '#get_game' do
    # All of this data is from match_v3_example_response
    let(:game_id) { 2513935315 }
    let(:create_time) { Time.at(1496381604616 / 1000) }
    let(:participants) { build_participants }

    context 'when successful' do
      it 'returns Game object' do
        stub_request(:any, /.*/)
          .to_return(
            status: 200,
            body: File.read('./spec/lib/riot_api/match_v3_example_response')
          )

        game = client.get_game(game_id)

        expect(game.game_id).to eq(game_id)
        expect(game.create_time).to eq(create_time)
        expect(game.participants).to eq(participants)
      end
    end

    context 'when invalid game id' do
      it 'raises client error' do
        stub = stub_request(:any, /.*/)

        expect{ client.get_game('a') }.to raise_error(RiotApi::Errors::ClientError)
        expect(stub).to_not have_been_requested
      end
    end

    context 'when 500' do
      it 'raises server error' do
        stub_request(:any, /.*/).to_return(status: 500)

        expect{ client.get_game(game_id) }.to raise_error(RiotApi::Errors::ServerError)
      end
    end

    context 'when 400' do
      it 'raises client error' do
        stub_request(:any, /.*/).to_return(status: 400)

        expect{ client.get_game(game_id) }.to raise_error(RiotApi::Errors::ClientError)
      end
    end

    context 'when 429' do
      it 'raises throttled error' do
        stub_request(:any, /.*/).to_return(status: 429)

        expect{ client.get_game(game_id) }.to raise_error(RiotApi::Errors::ThrottledError)
      end
    end
  end

  describe '#get_summoner' do
    let(:name) { 'all3nvan' }

    context 'when successful' do
      it 'returns Summoner object' do
        stub_request(:any, /.*/)
          .to_return(
            status: 200,
            body: File.read('./spec/lib/riot_api/summoner_v3_example_response')
          )

        summoner = client.get_summoner(name)

        expect(summoner.name).to eq(name)
        expect(summoner.summoner_id).to eq(23472148)
      end

      it 'escapes URIs' do
        expected_uri_component = /dat%20hass/
        stub = stub_request(:get, expected_uri_component)
          .to_return(
            status: 200,
            body: File.read('./spec/lib/riot_api/summoner_v3_example_response')
          )

        client.get_summoner('dat hass')

        expect(stub).to have_been_requested
      end
    end

    context 'when invalid name' do
      it 'raises client error' do
        stub = stub_request(:any, /.*/)

        expect{ client.get_summoner('%%%') }.to raise_error(RiotApi::Errors::ClientError)
        expect(stub).to_not have_been_requested
      end
    end

    context 'when 500' do
      it 'raises server error' do
        stub_request(:any, /.*/).to_return(status: 500)

        expect{ client.get_summoner(name) }.to raise_error(RiotApi::Errors::ServerError)
      end
    end

    context 'when 400' do
      it 'raises client error' do
        stub_request(:any, /.*/).to_return(status: 400)

        expect{ client.get_summoner(name) }.to raise_error(RiotApi::Errors::ClientError)
      end
    end

    context 'when 429' do
      it 'raises throttled error' do
        stub_request(:any, /.*/).to_return(status: 429)

        expect{ client.get_summoner(name) }.to raise_error(RiotApi::Errors::ThrottledError)
      end
    end
  end

  private

  def build_participants
    [
      RiotApi::Participant.new({
        team: 'BLUE',
        champion_id: 25,
        win: false,
        kills: 0,
        deaths: 6,
        assists: 7
      }),
      RiotApi::Participant.new({
        team: 'BLUE',
        champion_id: 202,
        win: false,
        kills: 1,
        deaths: 3,
        assists: 7
      }),
      RiotApi::Participant.new({
        team: 'BLUE',
        champion_id: 64,
        win: false,
        kills: 7,
        deaths: 9,
        assists: 4
      }),
      RiotApi::Participant.new({
        team: 'BLUE',
        champion_id: 10,
        win: false,
        kills: 2,
        deaths: 6,
        assists: 1
      }),
      RiotApi::Participant.new({
        team: 'BLUE',
        champion_id: 4,
        win: false,
        kills: 2,
        deaths: 6,
        assists: 4
      }),
      RiotApi::Participant.new({
        team: 'RED',
        champion_id: 236,
        win: true,
        kills: 9,
        deaths: 2,
        assists: 11
      }),
      RiotApi::Participant.new({
        team: 'RED',
        champion_id: 53,
        win: true,
        kills: 1,
        deaths: 2,
        assists: 17
      }),
      RiotApi::Participant.new({
        team: 'RED',
        champion_id: 98,
        win: true,
        kills: 2,
        deaths: 3,
        assists: 17
      }),
      RiotApi::Participant.new({
        team: 'RED',
        champion_id: 245,
        win: true,
        kills: 6,
        deaths: 2,
        assists: 7
      }),
      RiotApi::Participant.new({
        team: 'RED',
        champion_id: 104,
        win: true,
        kills: 12,
        deaths: 3,
        assists: 6
      })
    ]
  end
end
