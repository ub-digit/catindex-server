class V1::UsersController < V1::V1Controller
  before_filter -> { validate_rights 'admin' }

  def index
    @response[:users] = User.all
    render_json
  end

  def create
    user = User.new(user_params)
    
    # Save user, or return error message
    if !user.save
      error_msg(ErrorCodes::VALIDATION_ERROR, "Could not create user", user.errors)
      render_json
    else
      @response[:user] = user
      render_json(201)
    end
  end

  def user_params
    params.require(:user).permit(:username, :password, :role)
  end
end
