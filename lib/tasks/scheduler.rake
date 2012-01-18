namespace :momeant do

  desc "This sends an email digest of recent activity to users that have any"
  task :send_digests => :environment do
      puts "Sending activity digest emails to users..."
      User.send_activity_digests
      puts "done."
  end

end