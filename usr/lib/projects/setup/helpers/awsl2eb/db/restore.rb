# frozen_string_literal: true

require 'io/console'
require 'json'

module Awsl2eb
  module Db
    class Restore
      def initialize(config_path)
        @config_path = config_path
      end

      def from_s3_file(s3_file)
        puts "\nRestoring from S3 file: #{s3_file}\n\n"

        load_config
        collect_config
        save_config

        gpg_file = download_from_file_s3(s3_file)
        gz_file = decrypt_gpg_file(gpg_file)
        sql_file = gunzip_file(gz_file)

        case @db_type
        when 'mysql'
          execute(%Q(/usr/bin/mysql --host=#{@db_host} --port=#{@db_port} --user=#{@db_username} --password=#{@db_password} #{@db_database} < "#{sql_file}"))
        when 'pg'
          execute(%Q(PGPASSWORD=#{@db_password} /usr/bin/dropdb --host #{@db_host} --port #{@db_port} --username=#{@db_username} --if-exists --force #{@db_database}))
          execute(%Q(PGPASSWORD=#{@db_password} /usr/bin/createdb --host #{@db_host} --port #{@db_port} --username=#{@db_username} #{@db_database}))
          execute(%Q(PGPASSWORD=#{@db_password} /usr/bin/pg_restore --no-owner --host #{@db_host} --port #{@db_port} --username=#{@db_username} -d #{@db_database} "#{sql_file}"), abort_on_error: false)
        else
          abort("Unsupported database type: `#{@db_type}`")
        end

        puts "\n\nDatabase restored successfully!'\n\n"
      end

      def gunzip_file(gz_file)
        sql_file = File.expand_path(File.join(@tmp_path, File.basename(gz_file, '.gz')))

        puts "\nUnzipping `#{gz_file}` to `#{sql_file}`"

        File.unlink(sql_file) if File.exist?(sql_file)

        execute(%Q(/usr/bin/gunzip "#{gz_file}"))

        abort "File `#{sql_file}` not found" unless File.exist?(sql_file)

        sql_file
      end

      def decrypt_gpg_file(gpg_file)
        gz_file = File.expand_path(File.join(@tmp_path, File.basename(gpg_file, '.gpg')))

        puts "\nDecrypting `#{gpg_file}` to `#{gz_file}`"

        File.unlink(gz_file) if File.exist?(gz_file)

        execute(%Q(/usr/bin/gpg --decrypt --output "#{gz_file}" "#{gpg_file}"))

        abort "File `#{gz_file}` not found" unless File.exist?(gz_file)

        gz_file
      end

      def download_from_file_s3(s3_file)
        gpg_file = File.expand_path(File.join(@tmp_path, File.basename(s3_file)))

        puts "\nDownloading file from `#{s3_file}` to `#{gpg_file}`"

        File.unlink(gpg_file) if File.exist?(gpg_file)

        execute(%Q(/usr/local/bin/aws s3 cp "#{s3_file}" "#{gpg_file}" --profile #{@aws_profile}))

        abort "File `#{gpg_file}` not found" unless File.exist?(gpg_file)

        gpg_file
      end

      def config_file
        @config_file ||= "#{@config_path}/.awsl2eb/db-restore.json"
      end

      def load_config
        unless File.exist?(config_file)
          puts "Config file not found: #{config_file}"
          return false
        end

        settings = JSON.parse(File.read(config_file))

        @aws_profile = settings['awsProfile']
        @tmp_path = settings['tmpPath']
        @db_type = settings['dbType']
        @db_host = settings['dbHost']
        @db_port = settings['dbPort']
        @db_username = settings['dbUsername']
        @db_database = settings['dbDatabase']

        puts "Config loaded from: #{config_file}"
      end

      def collect_config
        @aws_profile = ask(@aws_profile, "What is the AWS profile that you wish to use to connect?")
        @tmp_path = ask(@tmp_path, "Where would you like to store the file to?", default: "~/Dump/")
        @db_type = ask(@db_type, "Database type (mysql, pg)?", default: "mysql")
        @db_host = ask(@db_host, "Database host", default: "127.0.0.1")
        @db_port = ask(@db_port, "Database port", default: "4306")
        @db_username = ask(@db_username, "Database username", default: "root")
        @db_password = ask(@db_password, "Database password", default: "", allow_blank: true, password: true)
        @db_database = ask(@db_database, "Database")

      end

      def save_config
        FileUtils.mkdir_p(File.dirname(config_file))

        File.write(config_file, JSON.pretty_generate({
          'awsProfile' => @aws_profile,
          'tmpPath' => @tmp_path,
          'dbType' => @db_type,
          'dbHost' => @db_host,
          'dbPort' => @db_port,
          'dbUsername' => @db_username,
          'dbDatabase' => @db_database,
        }))

        puts "Config saved to: #{config_file}"
      end

      def ask(value, question, default: nil, allow_blank: false, password: false)
        return value unless value.to_s.empty?

        formatted_question = question.dup
        formatted_question << " (enter for default: `#{default}`)" unless default.to_s.empty?
        formatted_question << " "

        print formatted_question
        value = password ? $stdin.noecho(&:gets).chomp : $stdin.gets.chomp.strip
        value = default.to_s.strip if value.empty?

        puts "" if password

        abort "Input value for `#{question}` is needed! Aborting." if value.empty? && !allow_blank

        value
      end

      def execute(command, abort_on_error: true)
        puts "\n\t#{command}\n\n"

        result = system(command)

        abort "Command failed" if abort_on_error && !result
      end
    end
  end
end