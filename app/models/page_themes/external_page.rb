require 'cgi'

class ExternalPage < Page
  
  def partial_name
    "external"
  end
  
  def css_class
    "external"
  end
  
  def parse_youtube_embed
    url = self.text
    query_params = CGI.parse(URI.parse(url).query)
    Rails.logger.info "------------------"
    Rails.logger.info query_params
    query_params["v"].present? ? query_params["v"].first : ""
  end
  
  def empty?
    false
  end
end