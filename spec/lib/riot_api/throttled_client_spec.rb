require 'rails_helper'

RSpec.describe RiotApi::ThrottledClient do
  describe '#get_summoner' do
    it 'tests the Riot API rate limit', skip: "Only run this test when integration testing the throttling logic" do
      WebMock.allow_net_connect!
      client = RiotApi::ThrottledClient.new
      105.times do |i|
        puts "##{i + 1}"
        client.get_summoner('all3nvan')
      end
    end
  end
end
