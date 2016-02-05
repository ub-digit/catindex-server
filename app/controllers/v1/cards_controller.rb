class V1::CardsController < V1::V1Controller
  before_filter -> { validate_rights 'admin' }, only: [:index]

  def index
    pagination = {}
    query = {}
    ipac_image_id = params[:image_id] || ''
    sortfield = params[:sortfield] || 'ipac_image_id'
    sortdir = params[:sortdir] || 'ASC'

    problem = params[:problem] || 'all'
    add_ipac_mismatch = false

    @cards = Card.paginate(page: params[:page])
    if @cards.current_page > @cards.total_pages
      @cards = Card.paginate(page: 1)
    end

    if ipac_image_id.present?
      @cards = @cards.where(ipac_image_id: ipac_image_id)
    else
      if (problem == 'admin_problems')
        @cards = Card.admin_problems(@cards)
      end
      if (problem == 'review_problems')
        @cards = Card.review_problems(@cards)
      end
      if (problem == 'all_problems')
        @cards = Card.all_problems(@cards)
      end
      if (problem == 'indexed_ipac_lookup_cards')
        @cards = Card.indexed_ipac_lookup_cards(@cards)
        add_ipac_mismatch = true
      end
      if (problem == 'ipac_lookup_cards_with_mismatch')
        @cards = Card.ipac_lookup_cards_with_mismatch(@cards)
        add_ipac_mismatch = true
      end
    end

    #@cards = @cards.where.not(tertiary_registrator_end: nil) if level == ''

    @cards = @cards.order(sortfield)
    @cards = @cards.reverse_order if sortdir.upcase == 'DESC'

    pagination[:pages] = @cards.total_pages
    pagination[:page] = @cards.current_page
    pagination[:next] = @cards.next_page
    pagination[:previous] = @cards.previous_page

    query[:total] = @cards.total_entries

    if(add_ipac_mismatch)
      @cards = @cards.map do |card|
        card = card.as_json
        card['ipac_lookup_mismatch']= true if card['ipac_lookup'] != card['lookup_field_value']
        card
      end
    end

    render json: {cards: @cards, meta: {pagination: pagination, query: query}}, status: 200
  end

  def show
    username = @current_user.username

    identifier = params[:identifier]

    if identifier == "sample"
      if @current_user.has_right?("admin")
        card = Card.sample_card
      else
        error_msg(ErrorCodes::PERMISSION_ERROR, "You don't have the necessary rights to perform this action")
        render_json
        return
      end
    end

    if identifier == "primary"
      # Find card for primary registration
      card = Card.where("primary_registrator_start IS NULL OR (now() > primary_registrator_start + interval '1' day)").where(primary_registrator_end: nil).order(:ipac_image_id).first
      if card && !card.update_attributes(primary_registrator_username: username, primary_registrator_start: Time.now)
        error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card", card.errors)
        render_json
        return
      elsif card
        previous_card_lookup_value = card.previous_card_lookup_value
        card = card.as_json.merge(previous_card_lookup_value: previous_card_lookup_value)
      end
    end

    if identifier == "secondary"
      # Find card for primary registration
      cards = Card.where.not(primary_registrator_username: username).where.not(primary_registrator_end: nil).where("secondary_registrator_start IS NULL OR (now() > secondary_registrator_start + interval '1' day)").where(secondary_registrator_end: nil).order(:ipac_image_id)
      card = cards.first
      if card && !card.update_attributes(secondary_registrator_username: username, secondary_registrator_start: Time.now)
        error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card", card.errors)
        render_json
        return
      end
    end

    # Find Card by ipac_image_id if identifier is numeric and user is admin
    if (@current_user.has_right?('admin'))
      if (identifier =~ /[\d]+/ )
        card = Card.find_by_ipac_image_id(identifier)
        if card && !card.update_attributes(tertiary_registrator_username: username, tertiary_registrator_start: Time.now)
          error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card", card.errors)
          render_json
          return
        end
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

        if registration_type == "secondary"
          if !card.update_attributes({secondary_registrator_values: card.registrator_json,
                                 secondary_registrator_problem: card_params[:secondary_registrator_problem],
                                 secondary_registrator_end: Time.now})
            error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card #{card.id}", card.errors)
            raise ActiveRecord::Rollback
          end
        end

        if registration_type == "tertiary"
          if !card.update_attributes({tertiary_registrator_values: card.registrator_json,
                                 tertiary_registrator_problem: card_params[:tertiary_registrator_problem],
                                 tertiary_registrator_end: Time.now})
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
    params.require(:card).permit(:card_type, :classification, :collection, :lookup_field_value, :lookup_field_type, :title, :year_from, :year_to, :no_year, :reference_text, :additional_authors => [])
  end
end
