class IndexController < ApplicationController
  def index
    @current_user_id = session[:user_id]
    @current_user_name = session[:user_name]
  end
end

