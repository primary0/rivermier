task :database_cleanup => :environment do
  Rake::Task["maintenance:database_cleanup"].reenable
  Rake::Task["maintenance:database_cleanup"].invoke
end

task :collect_users => :environment do
  Rake::Task["maintenance:collect_users"].reenable
  Rake::Task["maintenance:collect_users"].invoke
end