task :basic_test, [:number, :gout] => [:environment] do |t, args|
  number = (args[:number] || 8).to_i
  if args[:gout] == "true"
    gout = true
  else
    gout = false
  end
  Rake::Task[:rdb].invoke
  Rake::Task[:genusers].invoke(number, gout)
  puts "Testing scheduling"
  Rake::Task[:lunch].invoke
  Rake::Task[:outall].invoke
end
task :outall => :environment do
  User.all.each do |user|
    puts "User: " + user.id.to_s + ", type: " + user.foodtype + ", groupID: " + user.group_id.to_s
  end
  Group.all.each do |g|
    puts "Group: " + g.id.to_s + ", Number: " + g.users.length.to_s + ", Venue: " + g.venue.name + ", Type: " + g.foodtype
    puts "Users"
    g.users.each do |user|
      puts "User: " + user.id.to_s + ", type: " + user.foodtype + ", name: "+ user.name
    end
  end
end
