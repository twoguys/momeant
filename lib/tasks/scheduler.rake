namespace :momeant do

  desc "This sends an email digest of recent activity to users that have any"
  task :send_digests => :environment do
    puts "Sending activity digest emails to users..."

    current_month = Time.now.strftime("%B")
    first_monday = Chronic.parse("first monday in #{current_month}").yday
    third_monday = Chronic.parse("third monday in #{current_month}").yday
    today = Time.now.yday
    
    if today == first_monday || today == third_monday || ENV["ALWAYS_SEND_SCHEDULED_EMAILS"] == 'yes'
      puts "Ok, it's a first or third Monday, sending..."
      User.send_activity_digests
      puts "done."
    else
      puts "Today is not a first or third Monday."
    end
  end
  
  desc "This sends an email reminder to any patrons with pledged rewards over the reminder limit"
  task :send_pledge_reminders => :environment do
    puts "Sending pledge reminder emails to users..."

    current_month = Time.now.strftime("%B")
    second_monday = Chronic.parse("2nd monday in #{current_month}").yday
    today = Time.now.yday
    
    if today == second_monday || ENV["ALWAYS_SEND_SCHEDULED_EMAILS"] == 'yes'
      puts "Ok, it's a second Monday, sending..."
      User.send_pledge_reminders
      puts "done."
    else
      puts "Today is not a second Monday."
    end
  end

end