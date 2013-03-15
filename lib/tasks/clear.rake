task :rdb => :environment do
  # run at midnight, daily
  Group.delete_all
  User.find_by_keep(false).delete_all
  User.all.each do |user|
    user.keep = false
    user.matched = false
  end
  if Phase.first.nil?
    @phase = Phase.new()
    @phase.save
  end
  Phase.first.current = "dormant"
  Phase.first.save
  puts "Database reset"
end
task :mark => :environment do
  # run at 2:30
  if Phase.first.nil?
    @phase = Phase.new()
    @phase.save
  end
  Phase.first.current = "toolate"
  Phase.first.save
end

