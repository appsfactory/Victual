task :basic, [:number, :gout] => [:environment] do |t, args|
  number = (args[:number] || 8).to_i
  if args[:gout] == "1"
    gout = "1"
  else
    gout = "0"
  end
  puts gout
  Rake::Task[:rdb].invoke
  Rake::Task[:genusers].invoke(number, gout)
  puts "Testing scheduling"
  Rake::Task[:lunch].invoke
  Rake::Task[:outall].invoke
end
task :mixed, [:number, :num2] => [:environment] do |t, args|
  number = (args[:number] || rand(8)+1).to_i
  num2 =  (args[:num2] || Random.rand(8)+1).to_i
  Rake::Task[:rdb].invoke
  Rake::Task[:genusers].invoke(number, "1") 
  Rake::Task[:genusers].reenable
  Rake::Task[:genusers].invoke(num2, "0")
  puts "Testing scheduling"
  Rake::Task[:lunch].invoke
  Rake::Task[:outall].invoke
end
task :types, [:number, :num2, :num3] => [:environment] do |t, args|
  number = (args[:number] || rand(8)+1).to_i
  num2 =  (args[:num2] || 0).to_i
  num3 =  (args[:num3] || 0).to_i
  Rake::Task[:rdb].invoke
  Rake::Task[:genusers].invoke(number, "1", "standard") 
  Rake::Task[:genusers].reenable
  Rake::Task[:genusers].invoke(num2, "1", "foreign")
  Rake::Task[:genusers].reenable
  Rake::Task[:genusers].invoke(num3, "1", "fastfood")
  puts "Testing scheduling"
  Rake::Task[:lunch].invoke
  Rake::Task[:outall].invoke
end

task :outall => :environment do
  User.all.each do |user|
    puts "User: " + user.id.to_s + ", type: " + user.foodtype + ", groupID: " + user.group_id.to_s + ", Out: " + user.going_out.to_s
  end
  Group.all.each do |g|
    if g.venue
      name = g.venue.name
    else
      name = "Packed Lunch"
    end
    puts "Group: " + g.id.to_s + ", Number: " + g.users.length.to_s + ", Venue: " + name + ", Type: " + g.foodtype
    puts "Users"
    g.users.each do |user|
      puts "User: " + user.id.to_s + ", type: " + user.foodtype + ", name: "+ user.name + ", Out: " + user.going_out.to_s
    end
  end
end
