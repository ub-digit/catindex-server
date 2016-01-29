class V1::CardsController < V1::V1Controller

  def show
    username = @current_user.username
    
    registration_type = params[:registration_type]

    if registration_type == "primary"
      # Find card for primary registration
      card = Card.where(primary_registrator_start: nil).order(:ipac_image_id).first
      if !card.update_attributes(primary_registator_username: username, primary_registrator_start: Time.now)
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
