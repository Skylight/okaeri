# frozen_string_literal: true

require_relative 'backup/rclone_builder'
require_relative 'notify'

module Okaeri
  module Notify
    class MyTime
      def self.success(name, message)
        self.deliver!(name, message, success: true)
      end

      def self.failure(name, message)
        self.deliver!(name, message, success: false)
      end

      def self.deliver!(name, message, success: true)
        body = {
          channel: 'event',
          icon: success ? 'fa-hdd-o green' : 'fa-hdd-o red',
          name: success ? "#{name} - Success" : "#{name} - Error",
          description: message,
          user: 'backup'
        }

        HTTParty.post('https://mytime.skylight.be/api/status/json', headers: { 'Content-Type' => 'application/json' }, body: body.to_json)
      end
    end
  end
end