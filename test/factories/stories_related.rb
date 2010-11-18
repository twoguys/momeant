Factory.sequence :topic_name do |n|
  "Topic#{n}"
end

Factory.define :topic do |topic|
  topic.name    { Factory.next(:topic_name) }
end