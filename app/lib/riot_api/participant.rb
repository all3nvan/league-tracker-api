module RiotApi
  class Participant
    attr_reader :team, :champion_id, :win, :kills, :deaths, :assists

    def initialize(args)
      @team = args[:team]
      @champion_id = args[:champion_id]
      @win = args[:win]
      @kills = args[:kills]
      @deaths = args[:deaths]
      @assists = args[:assists]
    end
  end
end
