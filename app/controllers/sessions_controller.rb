class SessionsController < Devise::SessionsController
  before_filter :release_lockdown, :except => [:new, :create]
end