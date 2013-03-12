task :gen, [:repeat, :going_out, :type, :dist, :timeS, :timeE] => [:environment] do |t, args|
  if args[:type]
    has_pref = true
  else
    has_pref = false
  end
  type = args[:type] || 'any'
  repeat    = (args[:repeat] || 0).to_i
  timeS = (args[:timeS] || 1100).to_i
  timeE = (args[:timeE] || 1500).to_i
  dist = (args[:dist] || 1000).to_i
  if  args[:going_out] == "1"
    going_out = true
  else
    going_out = false
  end
  if User.last
    first = User.last.id + 1
    last = User.last.id + repeat
  else
    first = 0
    last = repeat
  end
  puts first, last
  for i in first..last
    name = "name" + i.to_s
    email =  name+"@g.cm"
    @user = User.new(dist: dist, email: email, name: name, has_pref: has_pref, start: timeS,
             :end => timeE, accepted: false, matched: false, foodtype: type, going_out: going_out,
                    distance: dist, timeStart: timeS, timeEnd: timeE)
    while User.where("token = ?", @user.token) and @user.token.nil?
      @user.token = SecureRandom.urlsafe_base64
    end 
    if @user.save
      puts "Success!"
    else
      puts "fail"
      puts @user.attributes
    end
  end
end

