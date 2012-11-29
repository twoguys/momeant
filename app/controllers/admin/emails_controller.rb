class Admin::EmailsController < Admin::BaseController
  
  def create
    params[:to].split(",").each do |to|
      NotificationsMailer.flexible_email(to, params[:from], params[:subject], params[:body]).deliver
    end
    redirect_to new_admin_email_path, notice: "Emails sent"
  end
  
end