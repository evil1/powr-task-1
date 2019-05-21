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
end

