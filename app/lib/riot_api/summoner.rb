module RiotApi
  class Summoner
    attr_reader :summoner_id, :name

    def initialize(args)
      @summoner_id = args[:summoner_id]
      @name = args[:name]
    end
  end
end
