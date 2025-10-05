# frozen_string_literal: true

require 'yaml'
require 'erb'

module Okaeri
  class Backup

    class RcloneBuilder
      def initialize(profile_file, source, destination, options:)
        raise "Profile file #{profile_file} is missing or is unreadable" unless File.readable?(profile_file)

        @profile_path = File.dirname(profile_file)
        @profile = erb_yaml_file(profile_file)

        @source = source
        @destination = destination
        @options = options
      end

      def command
        @profile['profile']['command']
      end

      def compiled_command
        @compiled_command ||= build_compiled_command
      end

      def exclude_if_present
        exclude_if_present = File.join(@profile_path, 'exclude-if-present.txt')

        return nil unless File.exist?(exclude_if_present)

        File.read(exclude_if_present).split.reject { |line| line.empty? }.map { |line| "--exclude-if-present #{line}" }
      end

      def flags
        @profile['profile']['flags']
      end

      def filter_from
        filter_from_file = File.join(@profile_path, 'filter-from.txt')

        return nil unless File.exist?(filter_from_file)

        "--filter-from #{filter_from_file}"
      end


      def build_compiled_command
        command = [
          '/usr/bin/rclone',
          self.command,
          @source,
          @destination
        ]

        command << self.filter_from
        command << self.exclude_if_present

        if @options[:log_file]
          command << "--log-file #{@options[:log_file]}"
          command << "--log-level #{@options[:log_level]}"
          command << "--log-file-max-backups #{@options[:log_file_max_backups]}"
        end

        command << '--dry-run' if @options[:dry_run]
        command << self.flags

        command.reject { |element| element.empty? }.join(' ')
      end

      def erb_yaml_file(file)
        YAML.load(ERB.new(File.read(file)).result)
      end
    end
  end
end