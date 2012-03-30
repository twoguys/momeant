namespace :momeant do
  
  desc "Reload story thumbnail images"
  task :reload_story_thumbnails => :environment do
    Story.published.all.each do |story|
      story.reload_thumbnail!
    end
  end