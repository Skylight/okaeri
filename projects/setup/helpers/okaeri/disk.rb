require 'fileutils'

module Okaeri
  class Disk
    def self.ensure_path!(path)
      raise "`path` should contain a value" if path.to_s.empty?

      unless Dir.exist?(path)
        FileUtils.mkdir_p(path)
        puts "Created path #{path}"
      end
    end

    def self.ensure_mod!(mode, path)
      raise "File or Path should exist (#{path})" unless File.exist?(path)

      current_mode = File.stat(path).mode & 0777
      File.chmod(mode, path) if mode != current_mode
    end

    def self.touch!(file)
      FileUtils.touch(file)
    end
  end
end