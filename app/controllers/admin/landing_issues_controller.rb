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
    parse_creator_comments
    parse_content_comments
    @landing_issue.save
    redirect_to admin_landing_issues_path
  end
  
  def preview
    @issue = LandingIssue.find(params[:id])
    render "home/issues/#{@issue.position}"
  end
  
  private
  
  def find_issue
    @landing_issue = LandingIssue.find(params[:id])
  end
  
  def parse_creator_comments
    creator_comments = ""
    params[:creator_comments].each do |num, hash|
      creator_comments += "---#{hash[:id]}:#{hash[:text]}" if hash[:id].present? && hash[:text].present?
    end
    @landing_issue.creator_comments = creator_comments
  end
  
  def parse_content_comments
    content_comments = ""
    params[:content_comments].each do |num, hash|
      content_comments += "---#{hash[:id]}:#{hash[:text]}" if hash[:id].present? && hash[:text].present?
    end
    @landing_issue.content_comments = content_comments
  end
  
end