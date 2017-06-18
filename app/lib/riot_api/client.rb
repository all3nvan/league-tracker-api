module RiotApi
  class Client
    API_KEY = ENV['RIOT_API_KEY']
    BASE_URL = 'https://na1.api.riotgames.com/lol'

    private_constant :API_KEY, :BASE_URL

    def get_game(game_id)
      match_url = "#{BASE_URL}/match/v3/matches/#{game_id}"
      response = HTTParty.get(match_url, query: { api_key: API_KEY })

      handle_response(response, method(:build_game))
    end

    def get_summoner(name)
      summoner_url = "#{BASE_URL}/summoner/v3/summoners/by-name/#{name}"
      response = HTTParty.get(summoner_url, query: { api_key: API_KEY })

      handle_response(response, method(:build_summoner))
    end

    private

    def handle_response(response, response_builder)
      case response.code
        when 200
          response_builder.call(JSON.parse(response.body))
        when 400..415
          raise RiotApi::Errors::ClientError, error_message(response)
        when 429
          raise RiotApi::Errors::ThrottledError, error_message(response)
        when 500..504
          raise RiotApi::Errors::ServerError, error_message(response)
        else
      end
    end

    def build_game(game_hash)
      participants = game_hash['participants'].map do |participant_hash|
        build_participant(participant_hash)
      end

      RiotApi::Game.new({
        game_id: game_hash['gameId'],
        create_time: Time.at(game_hash['gameCreation'] / 1000),
        participants: participants
      })
    end

    def build_participant(participant_hash)
      stats = participant_hash['stats']

      RiotApi::Participant.new({
        kills: stats['kills'],
        deaths: stats['deaths'],
        assists: stats['assists'],
        win: stats['win'],
        team: participant_hash['teamId'] == 100 ? 'BLUE' : 'RED',
        champion_id: participant_hash['championId']
      })
    end

    def build_summoner(summoner_hash)
      RiotApi::Summoner.new({
        summoner_id: summoner_hash['id'],
        name: summoner_hash['name']
      })
    end

    def error_message(response)
      "Status: #{response.code}. Message: #{response.message}"
    end
  end
end
