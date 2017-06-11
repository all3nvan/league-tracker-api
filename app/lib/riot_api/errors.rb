module RiotApi
  module Errors
    class ServerError < StandardError
    end

    class ClientError < StandardError
    end

    class ThrottledError < StandardError
    end
  end
end
