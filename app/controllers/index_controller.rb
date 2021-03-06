class IndexController < ApplicationController
  def index
    @current_user_id = session[:user_id]
    @current_user_name = session[:user_name]
  end

  def logout
    reset_session
    redirect_to '/'
  end

  def login
    redirect_to helpers.generate_url('https://github.com/login/oauth/authorize', :client_id => Rails.application.config.github_client_id, :scope => 'public_repo user')
  end

  def callback

    tokenResponse = helpers.github_access_token(params['code'])
    if tokenResponse['success'] == true
      token = tokenResponse['token']
      userData = helpers.get_user_details(token)
      session[:user_id] = userData['id']
      session[:user_name] = userData['name']

      @user = User.where('external_id' => userData['id'])
      # Check if user record does not exists yet
      if @user.blank?
        @user = User.new
        @user.external_id = userData['id']
        @user.login = userData['login']
        @user.name = userData['name']
        @user.jsonObject = ActiveSupport::JSON.encode userData
        @user.save

        @notice = 'New user ' + userData['name'] + ' was successfully log in and details where saved to database'
      else
        @notice = userData['name'] + ' was successfully log in but, user data was already saved earlier'
      end

      getFileResult = helpers.get_file(userData['login'], token)

      @response = userData
      if getFileResult['success'] == true
        fileUpdateResult = helpers.insert_script_tags(getFileResult['content'])
        @response = fileUpdateResult['content']
        if fileUpdateResult['success'] == true
          updateResult = helpers.update_file(userData['login'], token, fileUpdateResult['content'], getFileResult['sha'])
          if updateResult['success'] == true
            @notice = 'File was successfully updated'
          else
            @notice = 'Something went wrong'
            @response = updateResult['message']
          end
        else
          @notice = 'Scripts where already added to the file'
        end
      else
        @notice = getFileResult['message']
      end

    else
      @response = tokenResponse['message']
    end
    #@user

  end
end

