Factory.define :purchase do |purchase|
  purchase.story    { Factory(:story) }
  purchase.payee    { |p| p.story.user }
  purchase.payer    { Factory(:email_confirmed_user) }
  purchase.amount   { |p| p.story.price }
end