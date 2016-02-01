class V1::UsersController < V1::V1Controller
  before_filter -> { validate_rights 'admin' }, except: [:statistics]

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

  def statistics
    user_id = params[:id]
    user = User.find_by_id(user_id)

    if user.present?
      user_statistics = {}
      user_statistics.merge!(primary_registered_card_count: user.primary_registered_card_count)
      user_statistics.merge!(secondary_registered_card_count: user.secondary_registered_card_count)
      user_statistics.merge!(available_for_secondary_registration_count: user.available_for_secondary_registration_count)

      @response[:user_statistics] = user_statistics
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "No user found with id: #{user_id}.")
      render_json
    end
  end
end
