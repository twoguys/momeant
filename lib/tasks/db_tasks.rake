namespace :momeant do
  namespace :db do
    
    desc "Insert a few sample topics"
    task :seed_topics => :environment do
      art = Topic.create(:name => "Art")
      Topic.create(:name => "Photography", :topic_id => art.id)
      Topic.create(:name => "Painting", :topic_id => art.id)
      Topic.create(:name => "Sculpture", :topic_id => art.id)
      Topic.create(:name => "Illustration", :topic_id => art.id)
      Topic.create(:name => "Business")
      Topic.create(:name => "Culture")
      design = Topic.create(:name => "Design")
      Topic.create(:name => "Fashion", :topic_id => design.id)
      Topic.create(:name => "Graphic Design", :topic_id => design.id)
      Topic.create(:name => "DIY")
      Topic.create(:name => "Education")
      Topic.create(:name => "Environment")
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
  
  namespace :activity do
    desc "Create Activity records for past actions"
    task :backdate => :environment do
      Activity.destroy_all
      
      Reward.all.each do |reward|
        Activity.create(
          :actor_id => reward.user_id,
          :recipient_id => reward.recipient_id,
          :action_type => "Reward",
          :action_id => reward.id,
          :created_at => reward.created_at)
        
        reward.ancestors.each do |ancestor|
          Activity.create(
            :actor_id => reward.user_id,
            :recipient_id => ancestor.user_id,
            :action_type => "Impact",
            :action_id => reward.id,
            :created_at => ancestor.created_at)
        end
      end
      
      Story.published.each do |story|
        Activity.create(
          :actor_id => story.user_id,
          :action_type => "Story",
          :action_id => story.id,
          :created_at => story.created_at)
      end
      
      AmazonPayment.paid.each do |payment|
        Activity.create(
          :actor_id => payment.payer_id,
          :action_type => "AmazonPayment",
          :action_id => payment.id,
          :created_at => payment.created_at)
      end
    end
  end
end