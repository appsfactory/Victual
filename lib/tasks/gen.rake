task :genusers, [:repeat, :going_out, :type, :timeS, :timeE, :dist] => [:environment] do |t, args|
  if args[:type]
    has_pref = true
  else
    has_pref = false
  end
  type = args[:type] || 'any'
  repeat    = (args[:repeat] || 2).to_i
  timeS = (args[:timeS] || 1100).to_i
  timeE = (args[:timeE] || 1500).to_i
  dist = (args[:dist] || 1000).to_i
  if  args[:going_out] = "1"
    going_out = true
  else
    going_out = false
  end
  first = (User.last.id||-1)+1
  last = (User.last.id||-1)+repeat
  for i in 0..10
    name = "name" + i.to_s
    email =  "rofl"+i.to_s+"@gmail.cm"

    @user = User.new(dist: dist, email: email, name: name, has_pref: has_pref, start: timeS,
             :end => timeE, accepted: false, matched: false, foodtype: type, going_out: going_out)
    @user.save!
  end
end

