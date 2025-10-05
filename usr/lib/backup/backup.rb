# frozen_string_literal: true

require_relative 'backup/rclone_builder'
require_relative 'notify'

module Okaeri
  class Backup
    def initialize(profiles_path, options:)
      raise "Unable to locate profiles path: #{profiles_path}" unless File.directory?(profiles_path)
      @profiles_path = profiles_path
      @options = options

      @debug = !!options[:debug]
    end

    def profiles
      @profiles ||= Dir.entries(@profiles_path).select { |path| File.directory?(File.join(@profiles_path, path)) && !path.start_with?('.') }
    end

    def run(profile, destination)
      debug "Running `#{profile}` to `#{destination}`"
      profile_path = File.join(@profiles_path, profile, 'profile.yml')
      debug "Using profile from: #{profile_path}"

      rclone = RcloneBuilder.new(profile_path, destination, options: @options)
      debug "Compiled command:\n\n  #{rclone.compiled_command}\n\n"

      return if debug?

      
    end

    def debug?
      @debug
    end

    def debug(messsage)
      return unless debug?

      puts messsage
    end
  end
end