# frozen_string_literal: true

module Okaeri
  module Notify
    class Watchdog
      def self.deliver!(watchdog, run, event, message = nil)
        HTTParty.post("https://mytime.skylight.be/api/radar/watchdog/#{watchdog}/#{run}/#{event}", body: { message: message })
      end
    end
  end
end