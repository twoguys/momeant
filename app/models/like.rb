class Like < Curation
  belongs_to :story, :counter_cache => true
end