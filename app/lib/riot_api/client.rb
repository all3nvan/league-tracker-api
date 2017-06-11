module RiotApi
  class Client
    API_KEY = Rails.application.secrets.riot_api_key
    BASE_URL = 'https://na1.api.riotgames.com/lol'

    private_constant :API_KEY, :BASE_URL

    def get_game(game_id)
      match_url = "#{BASE_URL}/match/v3/matches/#{game_id}"
      response = HTTParty.get(match_url, query: { api_key: API_KEY })

      case response.code
        when 200
          build_game(JSON.parse(response.body))
        # TODO: handle errors
        when 400..415
        when 429
        when 500..504
        else
      end
    end

    private

    def build_game(game_hash)
      participants = game_hash['participants'].map do |participant_hash|
        build_participant(participant_hash)
      end

      Game.new({
        game_id: game_hash['gameId'],
        create_time: Time.at(game_hash['gameCreation'] / 1000),
        participants: participants
      })
    end

    def build_participant(participant_hash)
      stats = participant_hash['stats']

      Participant.new({
        kills: stats['kills'],
        deaths: stats['deaths'],
        assists: stats['assists'],
        win: stats['win'],
        team: participant_hash['teamId'] == 100 ? 'BLUE' : 'RED',
        champion_id: participant_hash['championId']
      })
    end
  end
end
