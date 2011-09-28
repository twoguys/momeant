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
    id = CGI.parse(URI.parse(url).query)
    id["v"].present? ? id["v"] : ""
  end
end