module IndexHelper

  # Function generates valid URI base on the URL and params provided
  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

end
