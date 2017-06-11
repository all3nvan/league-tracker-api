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

    def ==(other_participant)
      team == other_participant.team &&
        champion_id == other_participant.champion_id &&
        win == other_participant.win &&
        kills == other_participant.kills &&
        deaths == other_participant.deaths &&
        assists == other_participant.assists
    end
  end
end
