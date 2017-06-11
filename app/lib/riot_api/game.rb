module RiotApi
  class Game
    attr_reader :game_id, :create_time, :participants

    def initialize(args)
      @game_id = args[:game_id]
      @create_time = args[:create_time]
      @participants = args[:participants]
    end
  end
end
