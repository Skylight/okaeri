namespace :az do

  namespace :ccp do

    CCP_PROJECT_ROOT_PATH = File.join(ENV['OKAERI_WORK_PATH'], 'AstraZeneca', 'az.contracts-commercial-policy')
    CCP_PROJECT_PATH = File.join(CCP_PROJECT_ROOT_PATH, 'az.contracts-commercial-policy')

    desc "Prepare DockerVolumes directories"
    task :prepare_docker_volumes_paths do
      docker_volumes_mssql_base_path = File.join(ENV['OKAERI_DOCKER_VOLUMES_PATH'], 'AstraZeneca', 'mssql', 'ccp')
      docker_volumes_mssql_data_path = File.join(docker_volumes_mssql_base_path, 'data')
      docker_volumes_mssql_log_path = File.join(docker_volumes_mssql_base_path, 'log')

      Okaeri::Disk.ensure_path!(docker_volumes_mssql_data_path)
      Okaeri::Disk.ensure_mod!(0777, docker_volumes_mssql_data_path)
      Okaeri::Disk.ensure_path!(docker_volumes_mssql_log_path)
      Okaeri::Disk.ensure_mod!(0777, docker_volumes_mssql_log_path)
    end

    desc "Checks out the project in the designated folder"
    task :checkout_project do
      Okaeri::Disk.ensure_path!(CCP_PROJECT_ROOT_PATH)

      unless File.directory?(CCP_PROJECT_PATH)
        Dir.chdir(CCP_PROJECT_ROOT_PATH) do
          `git clone git@github.com:Skylight/az.contracts-commercial-policy.git`
        end
      end
    end

    desc "Build Docker Images"
    task :build_docker_images do
      Dir.chdir(File.join(CCP_PROJECT_PATH, 'docker', 'az-ccp')) do
        `docker build -t az-ccp:local .`
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