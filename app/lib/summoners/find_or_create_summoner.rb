module Summoners
  class FindOrCreateSummoner
    def initialize(name)
      @name = name
    end

    def call
      return Summoner.find_by(name: name) if Summoner.exists?(name: name)
      fetch_summoner
      find_or_create_model_summoner
      set_model_summoner_name
      @model_summoner.save
      @model_summoner
    end

    private

    def name
      @name
    end

    def riot_api_client
      @riot_api_client ||= RiotApi::ThrottledClient.new
    end

    def fetch_summoner
      @riot_api_summoner = riot_api_client.get_summoner(name)
    end

    def find_or_create_model_summoner
      if Summoner.exists?(@riot_api_summoner.summoner_id)
        @model_summoner = Summoner.find(@riot_api_summoner.summoner_id)
      else
        @model_summoner = Summoner.new(summoner_id: @riot_api_summoner.summoner_id)
      end
    end

    def set_model_summoner_name
      @model_summoner.name = @riot_api_summoner.name
    end
  end
end
