module IndexHelper

  require 'net/http'
  require 'nokogiri'
  require 'base64'

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

  # Function performs GET request to 'https://api.github.com/repos/:owner/:repo/contents/:path'
  def get_file(login, token)
    begin
      uri = URI('https://api.github.com/repos/'+ login + '/evil1.github.io/contents/powr/index.html')
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = 'token ' + token

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res =  http.request(req)

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
        responseObject = ActiveSupport::JSON.decode res.body
        fileContent = Base64.decode64(responseObject['content'])

        response = { 'success' => true, 'content' => fileContent, 'sha' => responseObject['sha'] }

      else
        response = { 'success' => false, 'message' => 'Error receiving file: ' + res.value }
      end
    rescue Exception => ex
      response = { 'success' => false, 'message' => 'Error receiving file: ' + ex.message }
    end

    return response
  end

  # Function adds script tag to head and body sections if they are not there yet
  def insert_script_tags(fileContent)

    @doc = Nokogiri::HTML(fileContent)

    hasChanges = false

    headScript = @doc.at_css "head script"
    #check if head section already contains script
    if headScript == nil
      script = Nokogiri::HTML::DocumentFragment.parse '<script src="https://www.powr.io/powr.js"></script>'

      head = @doc.at_css "head"
      head << script

      hasChanges = true
    end

    bodyScript = @doc.at_css "body script"
    #check if body section already contains script
    if bodyScript == nil
      script = Nokogiri::HTML::DocumentFragment.parse '<script src="https://www.powr.io/powr.js"></script>'

      body = @doc.at_css "body"
      body << script

      hasChanges = true
    end

    return { 'success' => hasChanges, 'content' => @doc.to_html }

  end

  # Function perform a PUT request to https://api.github.com/repos/:owner/:repo/contents/:path and performs a commit of a file
  def update_file(login, token, fileContent, sha)
    begin
      uri = URI('https://api.github.com/repos/'+ login + '/evil1.github.io/contents/powr/index.html')
      putParams = { "message" => "Inserted script into head and body sections",
                    "committer" =>  {
                        "name" => "Dmitriy Gritsenko",
                        "email" => "evil1@inbox.ru"
                    },
                    "content" => Base64.encode64(fileContent),
                    "sha" => sha
      }

      req = Net::HTTP::Put.new(uri)
      req['Authorization'] = 'token ' + token
      req['Accept'] = 'application/json'
      req.body = ActiveSupport::JSON.encode putParams

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res =  http.request(req)

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
        response = { 'success' => true, 'message' => res.body }
      else
        response = { 'success' => false, 'message' => 'Error updating file: ' + res.value }
      end

    rescue Exception => ex
      response = { 'success' => false, 'message' => 'Error updating file: ' + ex.message }
    end

    return response
  end

end
