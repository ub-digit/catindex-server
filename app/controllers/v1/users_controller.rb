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
    username = params[:id]
    u = User.find_by_username(username)

    if u.present?
      user = {}
      statistics = {}
      statistics.merge!(primary_registered_card_count: u.primary_registered_card_count)
      statistics.merge!(secondary_registered_card_count: u.secondary_registered_card_count)
      statistics.merge!(available_for_secondary_registration_count: u.available_for_secondary_registration_count)
      if u.role == 'ADMIN'
        totals = {}
        totals.merge!(card_count: Card.card_count)
        totals.merge!(primary_ended_card_count: Card.primary_ended_card_count)
        totals.merge!(secondary_ended_card_count: Card.secondary_ended_card_count)
        totals.merge!(tertiary_ended_card_count: Card.tertiary_ended_card_count)
        totals.merge!(not_started_card_count: Card.not_started_card_count)
        statistics.merge!(totals: totals)
      end
      user.merge!(statistics: statistics)

      @response[:user] = user
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "No user found with username: #{username}.")
      render_json
    end
  end
end
