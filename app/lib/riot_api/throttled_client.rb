module RiotApi
  class ThrottledClient
    MAX_CALLS_PER_THROTTLING_PERIOD = 10

    private_constant :MAX_CALLS_PER_THROTTLING_PERIOD

    def get_game(game_id)
      throttle_check
      client.get_game(game_id)
    end

    def get_summoner(name)
      throttle_check
      client.get_summoner(name)
    end

    private

    def client
      @client ||= RiotApi::Client.new
    end

    def throttle_check
      select_recent_request_times
      raise RiotApi::Errors::ThrottledError if should_throttle?
      request_times.push(Time.now)
    end

    def request_times
      @@request_times ||= []
    end

    def select_recent_request_times
      throttling_period = 11.seconds.ago
      current_time = Time.now
      request_times.select! { |time| (throttling_period..current_time).include?(time) }
    end

    def should_throttle?
      request_times.count >= MAX_CALLS_PER_THROTTLING_PERIOD
    end
  end
end
