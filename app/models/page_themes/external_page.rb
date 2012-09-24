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
    query = URI.parse(url).query
    return "" if query.nil?
    query_params = CGI.parse(query)
    query_params["v"].present? ? query_params["v"] : ""
  end
  
  def empty?
    false
  end
end