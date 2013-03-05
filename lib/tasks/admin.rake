task :admin => :environment do
   	@admin = Admin.new
   	@admin.name = 'admin'
   	@admin.save!
end