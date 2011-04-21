Factory.sequence :topic_name do |n|
  "Topic #{n}"
end

Factory.define :topic do |topic|
  topic.name        { Factory.next :topic_name }
end

Factory.sequence :story_name do |n|
  "Story #{n}"
end

Factory.define :story do |story|
  story.title       { Factory.next :story_name }
  story.synopsis    { "Lorem ipsum dolor sit amet, consectetur adipisicing elit."}
  story.price       0.50
  story.topics      { [Factory(:topic), Factory(:topic)] }
  story.user        { Factory :creator }
  story.autosaving  true # this gets around the at-least-one-page requirement
  story.published   true
end

Factory.define :free_story, :parent => :story do |story|
  story.price       0.0
end

Factory.define :crazy_expensive_story, :parent => :story do |story|
  story.price       1000.0  # that @%$# is ballin'
end

Factory.define :draft_story, :parent => :story do |story|
  story.published   false
  story.autosaving  true
end

Factory.define :bookmark do |bookmark|
  bookmark.story    { Factory :story }
  bookmark.user     { Factory :email_confirmed_user }
end

Factory.define :recommendation do |recommendation|
  recommendation.user     { Factory :user }
  recommendation.story    { Factory :story }
end

Factory.define :reward do |reward|
  reward.user               { Factory :user }
  reward.recipient          { Factory :creator }
  reward.story              { |r| Factory :story, :user => r.recipient }
end

Factory.define :page, :class => "TitlePage" do |p|
end

Factory.sequence :tag_name do |n|
  "Tag #{n}"
end

Factory.define :tagged_story, :parent => :story do |story|
  story.tag_list      { "#{Factory.next :tag_name}, #{Factory.next :tag_name}" }
end