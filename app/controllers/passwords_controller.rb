class PasswordsController < Devise::PasswordsController
  skip_before_filter :release_lockdown
end