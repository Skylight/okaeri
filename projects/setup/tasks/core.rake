namespace :core do
  desc "Checks working folders and creats them if needed"
  task :ensure_default_work_path_structure do
    Okaeri::Disk.ensure_path!(ENV['OKAERI_DOCKER_VOLUMES_PATH'])
    Okaeri::Disk.ensure_path!(ENV['OKAERI_TMP_PATH'])
    Okaeri::Disk.ensure_path!(ENV['OKAERI_WORK_PATH'])
  end
end