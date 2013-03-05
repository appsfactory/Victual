task :rdb => :environment do
  Group.delete_all
  User.delete_all
  puts "Database reset"
end
