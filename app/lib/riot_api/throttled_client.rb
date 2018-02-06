module RiotApi
  class ThrottledClient
    # Riot API rate limits (https://developer.riotgames.com/)
    # 20 requests every 1 seconds
    # 100 requests every 2 minutes
    MAX_CALLS_PER_SHORT_THROTTLING_PERIOD = 19
    MAX_CALLS_PER_LONG_THROTTLING_PERIOD = 99
    SHORT_THROTTLING_PERIOD = 1.second
    LONG_THROTTLING_PERIOD = 2.minutes

    private_constant :MAX_CALLS_PER_SHORT_THROTTLING_PERIOD
    private_constant :MAX_CALLS_PER_LONG_THROTTLING_PERIOD
    private_constant :SHORT_THROTTLING_PERIOD
    private_constant :LONG_THROTTLING_PERIOD

    def initialize
      @client = RiotApi::Client.new
    end

    def get_game(game_id)
      throttle_check
      @client.get_game(game_id)
    end

    def get_summoner(name)
      throttle_check
      @client.get_summoner(name)
    end

    private

    def throttle_check
      select_recent_request_times
      if should_throttle?
        raise RiotApi::Errors::ThrottledError, "Preventing too many requests to Riot API."
      end
      update_request_times
    end

    def short_period_request_times
      @@short_period_request_times ||= []
    end

    def long_period_request_times
      @@long_period_request_times ||= []
    end

    def select_recent_request_times
      short_throttle_period_start_time = SHORT_THROTTLING_PERIOD.ago
      long_throttle_period_start_time = LONG_THROTTLING_PERIOD.ago
      current_time = Time.now
      short_period_request_times.select! { |time| (short_throttle_period_start_time..current_time).include?(time) }
      long_period_request_times.select! { |time| (long_throttle_period_start_time..current_time).include?(time) }
    end

    def should_throttle?
      short_period_request_times.count >= MAX_CALLS_PER_SHORT_THROTTLING_PERIOD ||
        long_period_request_times.count >= MAX_CALLS_PER_LONG_THROTTLING_PERIOD
    end

    def update_request_times
      current_time = Time.now
      short_period_request_times.push(current_time)
      long_period_request_times.push(current_time)
    end
  end
end
