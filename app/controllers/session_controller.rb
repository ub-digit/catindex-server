class SessionController < ApplicationController
  def create
    username = params[:username]
    password = params[:password]
    user = User.find_by_username(username)
    if user
      token = user.authenticate(password)
      if token
        @response[:user] = {
          username: username,
          role: user.role
        }
        @response[:access_token] = token
        @response[:token_type] = "bearer"
        render_json
        return
      else
        error_msg(ErrorCodes::AUTH_ERROR, "Invalid credentials")
      end
    else
      error_msg(ErrorCodes::AUTH_ERROR, "Invalid credentials")
    end
    render_json
  end

  def show
    @response = {}
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token)
      @response[:user] = {
        username: token_object.user.username,
        role: token_object.user.role
      }
      @response[:access_token] = token
      @response[:token_type] = "bearer"
    else
      error_msg(ErrorCodes::SESSION_ERROR, "Invalid session")
    end
    render_json
  end
end
