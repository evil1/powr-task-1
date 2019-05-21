module IndexHelper

  require 'net/http'

  # Function generates valid URI base on the URL and params provided
  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  # Function performs a POST request to 'https://github.com/login/oauth/access_token' in order to receive an access token
  def github_access_token(code)
    uri = URI('https://github.com/login/oauth/access_token')
    req = Net::HTTP::Post.new(uri)
    # Set Accept type to app/json to receive response in JSON format
    req['Accept'] = 'application/json'
    req.set_form_data('client_id' => Rails.application.config.github_client_id, 'client_secret' => Rails.application.config.github_secret, 'code' => code)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res =  http.request(req)

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      # Parse JSON response
      tokenResponse = ActiveSupport::JSON.decode res.body
      if tokenResponse['access_token']
        response = { 'success' => true, 'token' => tokenResponse['access_token']}
      else
        response = { 'success' => false, 'message' => tokenResponse['error_description']}
      end
    else
      response = { 'success' => false, 'message' => 'Error receiving access_token: ' + res.value}
    end

    return response
  end


  # Function performs GET request to 'https://api.github.com/user' to retrieve user's details
  def get_user_details(token)
    uri = URI('https://api.github.com/user')
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = 'token ' + token

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res =  http.request(req)

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      responseText = ActiveSupport::JSON.decode res.body
    else
      responseText = 'Error receiving user details: ' + res.value
    end

    return responseText
  end

end
