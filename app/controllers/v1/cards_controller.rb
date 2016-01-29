class V1::CardsController < V1::V1Controller

  def show
    username = @current_user.username
    
    registration_type = params[:registration_type]

    if registration_type == "primary"
      # Find card for primary registration
      card = Card.where(primary_registrator_start: nil).order(:ipac_image_id).first
      if !card.update_attributes(primary_registrator_username: username, primary_registrator_start: Time.now)
        error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card", card.errors)
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

  def update
    username = @current_user.username

    card_params = params[:card]
    if !card_params
      error_msg(ErrorCodes::REQUEST_ERROR, "Must contain object 'card'")
      render_json
      return
    end

    registration_type = card_params[:registration_type]

   # Save card after primary registration
    card = Card.where(id: card_params[:id]).where("#{registration_type}_registrator_username = ?", username).first
    if !card
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find card with id #{card_params[:id]}")
      render_json
      return
    end

    Card.transaction do
      if card.update_attributes(update_card_params)
        
        if registration_type == "primary"
          if !card.update_attributes({primary_registrator_values: card.registrator_json,
                                 primary_registrator_problem: card_params[:primary_registrator_problem],
                                 primary_registrator_end: Time.now})
            error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card #{card.id}", card.errors)
            raise ActiveRecord::Rollback
          end
        end

        @response[:card] = card
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card #{card.id}", card.errors)
        raise ActiveRecord::Rollback
      end
    end

    render_json
  end

  def update_card_params
    params.require(:card).permit(:card_type, :classification, :collection, :lookup_field_value, :lookup_field_type, :title, :year_from, :year_to, :no_year, :additional_authors, :reference_text)
  end
end
