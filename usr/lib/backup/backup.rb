# frozen_string_literal: true

require_relative 'backup/rclone_builder'
require_relative 'notify'

module Okaeri
  class Backup

    attr_reader :source, :destination

    def initialize(source, destination, profile_file, options:)
      raise "Unable to locate profile: #{profile_file}" unless File.readable?(profile_file)

      @source = source
      @destination = destination
      @profile_file = profile_file
      @options = options

      @debug = !!@options[:debug]
      @watchdog = @options[:watchdog]

      debug
      debug "source:\t\t#{source}"
      debug "destination:\t#{destination}"
      debug "profile_file:\t#{profile_file}"
      debug
      debug "options:\t#{options.inspect}"
      debug
    end

    def compiled_command
      @compiled_command ||= RcloneBuilder.new(@profile_file, source, destination, options: @options).compiled_command
    end

    def run!
      run = "run-#{Time.now.to_i}"

      begin
        Okaeri::Notify::Watchdog.deliver!(@watchdog, run, 'begin') if watchdog?

        raise "Something went wrong with rclone `#{$?.exitstatus}`" unless system(self.compiled_command)

        Okaeri::Notify::Watchdog.deliver!(@watchdog, run, 'end') if watchdog?
        exit 0
      rescue => exception
        Okaeri::Notify::Watchdog.deliver!(@watchdog, run, 'error', exception.to_s) if watchdog?
        exit 1
      end
    end

    def debug?
      @debug
    end

    def watchdog?
      !!@watchdog
    end

    def debug(messsage = '')
      return unless debug?

      puts messsage
    end
  end
end