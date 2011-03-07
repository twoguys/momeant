class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :release_lockdown
end