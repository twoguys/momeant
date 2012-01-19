namespace :momeant do

  desc "This sends an email digest of recent activity to users that have any"
  task :send_digests => :environment do
    puts "Sending activity digest emails to users..."

    current_month = Time.now.strftime("%B")
    first_monday = Chronic.parse("first monday in #{current_month}").yday
    third_monday = Chronic.parse("third monday in #{current_month}").yday
    today = Time.now.yday
    
    if today == first_monday || today == third_monday
      puts "Ok, it's a first or third Monday, sending..."
      User.send_activity_digests
      puts "done."
    else
      puts "Today is not a first or third Monday."
    end
  end

end