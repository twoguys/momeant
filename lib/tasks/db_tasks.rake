namespace :momeant do
  namespace :db do
    
    desc "Insert a few sample topics"
    task :seed_topics => :environment do
      Topic.create(:name => "Art")
      Topic.create(:name => "Business")
      Topic.create(:name => "Culture")
      design = Topic.create(:name => "Design")
      Topic.create(:name => "DIY")
      Topic.create(:name => "Education")
      Topic.create(:name => "Environment")
      Topic.create(:name => "Fashion", :topic_id => design.id)
      Topic.create(:name => "Gastronomy")
      Topic.create(:name => "Health")
      Topic.create(:name => "History")
      Topic.create(:name => "Literature")
      Topic.create(:name => "Music")
      Topic.create(:name => "Journalism")
      Topic.create(:name => "Science")
      Topic.create(:name => "Sports")
      Topic.create(:name => "Technology")
      Topic.create(:name => "Travel")
    end
    
  end
end