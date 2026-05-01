namespace :awsl2 do
  namespace :restore do
    desc "Restore a database, dumped with the awsl2eb-db-dump path from S3"
    task :s3, [ :s3_file ] do |_, args|
      # The tasks creates a json file in the directory where it's executed and stores the settings (except password)
      # for easier recovery.

      @s3_file = args[:s3_file].to_s
      abort "Error: Pass in a filename to S3" if @s3_file.empty?

      @restore = Awsl2eb::Db::Restore.new(Dir.pwd)
      @restore.from_s3_file(@s3_file)
    end
  end
end
