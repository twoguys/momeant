Factory.sequence :topic_name do |n|
  "Topic #{n}"
end

Factory.define :topic do |topic|
  topic.name        { Factory.next(:topic_name) }
end

Factory.sequence :story_name do |n|
  "Story #{n}"
end

Factory.define :story do |story|
  story.title       { Factory.next(:story_name) }
  story.excerpt     { "Lorem ipsum dolor sit amet, consectetur adipisicing elit."}
  story.price       0.50
  story.topics      { [Factory(:topic), Factory(:topic)] }
  story.user        { Factory(:creator) }
end

Factory.define :free_story, :parent => :story do |story|
  story.price       0.0
end