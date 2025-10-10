namespace :az do

  namespace :aap do

    AAP_PROJECT_ROOT_PATH = File.join(ENV['OKAERI_WORK_PATH'], 'AstraZeneca', 'az.pegasus')
    AAP_PROJECT_PATH = File.join(AAP_PROJECT_ROOT_PATH, 'az.pegasus')

    desc "Prepare DockerVolumes directories"
    task :prepare_docker_volumes_paths do
      docker_volumes_mssql_base_path = File.join(ENV['OKAERI_DOCKER_VOLUMES_PATH'], 'AstraZeneca', 'mssql', 'aap')
      docker_volumes_mssql_data_path = File.join(docker_volumes_mssql_base_path, 'data')
      docker_volumes_mssql_log_path = File.join(docker_volumes_mssql_base_path, 'log')

      Okaeri::Disk.ensure_path!(docker_volumes_mssql_data_path)
      Okaeri::Disk.ensure_mod!(0777, docker_volumes_mssql_data_path)
      Okaeri::Disk.ensure_path!(docker_volumes_mssql_log_path)
      Okaeri::Disk.ensure_mod!(0777, docker_volumes_mssql_log_path)
    end

    desc "Checks out the project in the designated folder"
    task :checkout_project do
      Okaeri::Disk.ensure_path!(AAP_PROJECT_ROOT_PATH)

      unless File.directory?(AAP_PROJECT_PATH)
        Dir.chdir(AAP_PROJECT_ROOT_PATH) do
          `git clone git@github.com:Skylight/az.pegasus.git`
        end
      end

      Okaeri::Disk.ensure_path!(File.join(AAP_PROJECT_PATH, 'app', 'logs'))
    end

    desc "Build Docker Images"
    task :build_docker_images do
      Dir.chdir(File.join(AAP_PROJECT_PATH, 'docker', 'az-aap')) do
        `docker build -t az-aap:local .`
      end
      Dir.chdir(File.join(AAP_PROJECT_PATH, 'docker', 'webpack')) do
        `docker build -t webpack:local .`
      end
    end

    desc "Install Node & Packages (for asset building support)"
    task :install_node_and_packages do
      Dir.chdir(AAP_PROJECT_PATH) do
        system("bash", "-c", "source $HOME/.nvm/nvm.sh && nvm install")
        system("bash", "-c", "source $HOME/.nvm/nvm.sh && npm install")
      end
    end

    desc "Setup project"
    task setup: [
      'core:ensure_default_work_path_structure',
      :prepare_docker_volumes_paths,
      :checkout_project,
      :build_docker_images,
      :install_node_and_packages
    ] do; end

    desc "Dump database(s)"
    task :dump, [:name] do |t, args|
      dump_path = File.join(ENV['OKAERI_DUMP_PATH'], 'AstraZeneca', 'aap', 'latest')
      Okaeri::Disk.ensure_path!(dump_path)

      config_file = File.join(AAP_PROJECT_PATH, 'bootstrap', 'database.yml')
      raise "Unable to locate config file: #{config_file}" unless File.readable?(config_file)

      config = YAML.load_file(config_file, aliases: true).reject{|key| key == 'default'}


      if args[:name].nil?
        puts "\nChoose on of these:\n\n"

        config.keys.each do |name|
          puts "  #{name}"
        end
        puts "\n  or\n\n"
        puts "  *\n\n"
        puts "\tbake az:aap:dump[*]\n\n"
        exit 0
      end

      config.each do |name, settings|
        next if args[:name] != '*' && name != args[:name]

        adapter = settings['adapter']
        database = settings['database']
        username = settings['username']
        password = settings['password']

        raise "adapter `#{adapter}` is not supported" unless adapter == 'mssql'

        dump_file = File.join(dump_path, "#{database}.dacpac")

        puts
        puts "Dumping `#{database}` to `#{dump_file}`"
        puts

        command = %Q(sqlpackage /Action:Extract /SourceServerName:"localhost" /SourceDatabaseName:"#{database}" /TargetFile:"#{dump_file}" /SourceTrustServerCertificate:True /SourceUser:"#{username}" /SourcePassword:"#{password}" /p:IgnoreUserLoginMappings=True /p:ExtractAllTableData=True)
        puts
        puts "\t#{command}"
        puts
        raise "Something went wrong `#{$?.exitstatus}`" unless system(command)
      end
    end

    desc "Restore database(s)"
    task :restore, [:name] do |t, args|
      load_path = File.join(ENV['OKAERI_DUMP_PATH'], 'AstraZeneca', 'aap', 'latest')
      Okaeri::Disk.ensure_path!(load_path)

      config_file = File.join(AAP_PROJECT_PATH, 'bootstrap', 'database.yml')
      raise "Unable to locate config file: #{config_file}" unless File.readable?(config_file)

      config = YAML.load_file(config_file, aliases: true).reject{|key| key == 'default'}


      if args[:name].nil?
        puts "\nChoose on of these:\n\n"

        config.keys.each do |name|
          puts "  #{name}"
        end
        puts "\n  or\n\n"
        puts "  *\n\n"
        puts "\tbake az:aap:restore[*]\n\n"
        exit 0
      end

      config.each do |name, settings|
        next if args[:name] != '*' && name != args[:name]

        adapter = settings['adapter']
        database = settings['database']
        username = settings['username']
        password = settings['password']

        raise "adapter `#{adapter}` is not supported" unless adapter == 'mssql'

        load_file = File.join(load_path, "#{database}.dacpac")

        raise "Unable to locate load file: #{load_file}" unless File.readable?(load_file)

        puts
        puts "Restoring `#{load_file}` to `#{database}`"
        puts

        command = %Q(sqlpackage /Action:Publish /TargetServerName:"localhost" /TargetDatabaseName:"#{database}" /SourceFile:"#{load_file}" /TargetTrustServerCertificate:True /TargetUser:"#{username}" /TargetPassword:"#{password}" /p:CreateNewDatabase=True /p:ExcludeObjectTypes="Users;LinkedServerLogins;Logins;RoleMembership")
        puts
        puts "\t#{command}"
        puts
        raise "Something went wrong `#{$?.exitstatus}`" unless system(command)
      end
    end

  end

end