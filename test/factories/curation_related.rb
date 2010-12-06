Factory.define :bookmark do |bookmark|
  bookmark.story    { Factory :story }
  bookmark.user     { Factory :email_confirmed_user }
end