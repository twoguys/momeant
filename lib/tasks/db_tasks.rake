namespace :momeant do
  namespace :db do
    
    desc "Insert a few sample topics"
    task :seed_topics => :environment do
      Topic.create(:name => "Fashion")
      Topic.create(:name => "Design")
      Topic.create(:name => "Photography")
      Topic.create(:name => "Life")
    end
    
  end
end