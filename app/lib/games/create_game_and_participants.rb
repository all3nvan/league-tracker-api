module Games
  class CreateGameAndParticipants
    def initialize(game_id)
      @game_id = game_id
    end

    def call
      validate_uniqueness
      fetch_game
      convert_to_model_game
      @model_game.save
      @model_game
    end

    private

    def game_id
      @game_id
    end

    def riot_api_client
      @riot_api_client ||= RiotApi::ThrottledClient.new
    end

    def validate_uniqueness
      if Game.exists?(game_id: game_id)
        raise DuplicateGameError
      end
    end

    def fetch_game
      # TODO: handle exceptions
      @riot_api_game = riot_api_client.get_game(game_id)
    end

    def convert_to_model_game
      @model_game = Game.new(
        game_id: @riot_api_game.game_id,
        create_time: Time.at(@riot_api_game.create_time)
      )
      @model_game.game_participants.build(
        @riot_api_game.participants.map do |participant|
          {
            game: @model_game,
            team: participant.team,
            champion_id: participant.champion_id,
            win: participant.win,
            kills: participant.kills,
            deaths: participant.deaths,
            assists: participant.assists
          }
        end
      )
    end
  end
end
