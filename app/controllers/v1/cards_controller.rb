class V1::CardsController < ApplicationController

  def show
    username = params[:username]
    user = User.find_by_username(username)
      if !user
       error_msg(ErrorCodes::AUTH_ERROR, "Could not find user #{username}")
       render_json
       return
      end
    
    registration_type = params[:registration_type]

    if registration_type == "primary"
      # Find card for primary registration
      card = Card.where(primary_registrator_start: nil).first
      if !card.update_attributes(primary_registator_username: user.username, primary_registrator_start: Time.now)
        error_msg(ErrorCodes::OBJECT_ERROR, "Could not update card", card.errors)
        render_json
        return
      end
    end

    if card
      @response[:card] = card
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find a card")
    end

    render_json
  end
end
