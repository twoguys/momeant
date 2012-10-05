class Admin::LandingIssuesController < Admin::BaseController
  before_filter :find_issue, only: [:edit, :update]
  
  def index
    @landing_issues = LandingIssue.all
  end
  
  def create
    @issue = LandingIssue.create
    redirect_to edit_admin_landing_issue_path(@issue)
  end
  
  def update
    @landing_issue.update_attributes(params[:landing_issue])
    redirect_to admin_landing_issues_path
  end
  
  private
  
  def find_issue
    @landing_issue = LandingIssue.find(params[:id])
  end
  
end