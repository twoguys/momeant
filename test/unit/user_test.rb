require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "A creator who's story I've rewarded shows up in my rewarded creators list and I show up in their patrons list" do
    reward = Factory(:reward)
    reward.user.rewarded_creators.include?(reward.recipient)
    reward.recipient.patrons.include?(reward.user)
  end
  
  # DEPRECATED
  #
  # test "Momeant shows recommended stories from users I'm subscribed to" do
  #     user = Factory(:user)
  #     subscription = Factory(:subscription, :subscriber => user)
  #     recommendation = Factory(:recommendation, :user => subscription.user)
  # 
  #     assert user.recommended_stories_from_people_i_subscribe_to.include?(recommendation.story)
  #     assert user.recommendations_from_people_i_subscribe_to.include?(recommendation)
  #   end
  #   
  #   test "Momeant does NOT show recommended stories from users I'm subscribed to if I've created them" do
  #     creator = Factory(:creator)
  #     story = Factory(:story, :user => creator)
  #     subscription = Factory(:subscription, :subscriber => creator)
  #     recommendation = Factory(:recommendation, :story => story, :user => subscription.user)
  #     
  #     assert !creator.recommended_stories_from_people_i_subscribe_to.include?(story)
  #     assert !creator.recommendations_from_people_i_subscribe_to.include?(recommendation)
  #   end
  #   
  #   test "Momeant does NOT show recommended stories from users I'm subscribed to if I've already purchased them" do
  #     user = Factory(:user)
  #     subscription = Factory(:subscription, :subscriber => user)
  #     recommendation = Factory(:recommendation, :user => subscription.user)
  #     purchase = Factory(:purchase, :payer => user, :story => recommendation.story)
  # 
  #     assert !user.recommended_stories_from_people_i_subscribe_to.include?(recommendation.story)
  #     assert !user.recommendations_from_people_i_subscribe_to.include?(recommendation.story)
  #   end
  #   
  #   test "Momeant shows stories similar to my bookmarks" do
  #     user = Factory(:user)
  #     bookmark = Factory(:bookmark, :user => user)
  #     similar_story = Factory(:story, :topics => bookmark.story.topics)
  # 
  #     assert user.stories_similar_to_my_bookmarks_and_purchases.include?(similar_story)
  #   end
  #   
  #   test "Momeant does NOT show stories similar to my bookmarks if I've created them" do
  #     creator = Factory(:creator)
  #     story = Factory(:story, :user => creator)
  #     similar_story = Factory(:story, :topics => story.topics)
  #     another_similar_story = Factory(:story, :topics => story.topics)
  #     bookmark = Factory(:bookmark, :user => creator, :story => similar_story)
  #     
  #     # make sure the story I created isn't recommended to me
  #     assert !creator.stories_similar_to_my_bookmarks_and_purchases.include?(story)
  # 
  #     # but make sure the other story is still recommended
  #     assert creator.stories_similar_to_my_bookmarks_and_purchases.include?(another_similar_story)
  #   end
  #   
  #   test "Momeant does NOT show stories similar to my bookmarks if I've purchased them" do
  #     user = Factory(:user)
  #     bookmark = Factory(:bookmark, :user => user)
  #     similar_story = Factory(:story, :topics => bookmark.story.topics)
  #     purchase = Factory(:purchase, :payer => user, :story => similar_story)
  #     
  #     # make sure the story I purchased isn't recommended to me
  #     assert !user.stories_similar_to_my_bookmarks_and_purchases.include?(similar_story)
  #   end
  #   
  #   test "Momeant shows stories similar to my purchases" do
  #     user = Factory(:user)
  #     purchase = Factory(:purchase, :payer => user)
  #     similar_story = Factory(:story, :user => purchase.story.user)
  # 
  #     assert user.stories_similar_to_my_bookmarks_and_purchases.include?(similar_story)
  #   end
  #   
  #   test "Momeant does NOT show stories similar to my purchases if I've created them" do
  #     creator = Factory(:creator)
  #     purchase = Factory(:purchase, :payer => creator)
  #     similar_story = Factory(:story, :topics => purchase.story.topics, :user => creator)
  #     
  #     assert !creator.stories_similar_to_my_bookmarks_and_purchases.include?(similar_story)
  #   end
  #   
  #   test "Momeant does NOT show stories similar to my purchases if I've already purchased them" do
  #     user = Factory(:user)
  #     purchase = Factory(:purchase, :payer => user)
  #     similar_story = Factory(:story, :topics => purchase.story.topics)
  #     purchase = Factory(:purchase, :payer => user, :story => similar_story)
  #     
  #     assert !user.stories_similar_to_my_bookmarks_and_purchases.include?(similar_story)
  #   end
  #   
  #   test "Momeant does NOT show stories that are unpublished" do
  #     user = Factory(:user)
  #     purchase = Factory(:purchase, :payer => user)
  #     similar_story = Factory(:draft_story, :topics => purchase.story.topics)
  #     
  #     assert !user.stories_similar_to_my_bookmarks_and_purchases.include?(similar_story)
  #   end
    
end
