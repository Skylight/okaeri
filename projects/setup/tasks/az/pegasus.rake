namespace :az do

  namespace :pegasus do

    PROJECT_ROOT_PATH = File.join(ENV['OKAERI_WORK_PATH'], 'AstraZeneca', 'az.pegasus')
    PROJECT_PATH = File.join(PROJECT_ROOT_PATH, 'az.pegasus')

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
      Okaeri::Disk.ensure_path!(PROJECT_ROOT_PATH)
      Okaeri::Disk.touch!(File.join(PROJECT_ROOT_PATH, '.ignore-sync'))

      unless File.directory?(PROJECT_PATH)
        Dir.chdir(PROJECT_ROOT_PATH) do
          `git clone git@github.com:Skylight/az.pegasus.git`
        end
      end

      Okaeri::Disk.ensure_path!(File.join(PROJECT_PATH, 'app', 'logs'))
    end

    desc "Build Docker Images"
    task :build_docker_images do
      Dir.chdir(File.join(PROJECT_PATH, 'docker', 'az-aap')) do
        `docker build -t az-aap:local .`
      end
      Dir.chdir(File.join(PROJECT_PATH, 'docker', 'webpack')) do
        `docker build -t webpack:local .`
      end
    end

    desc "Setup project"
    task setup: [
      'core:ensure_default_work_path_structure',
      :prepare_docker_volumes_paths,
      :checkout_project,
      :build_docker_images
    ] do; end

  end

end