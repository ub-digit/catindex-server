class V1::CardsController < V1::V1Controller
  before_filter -> { validate_rights 'admin' }, only: [:index]

  def index
    pagination = {}
    query = {}
    # problem
    # all problem eller inte problem
    # all_problems mot+adm m problem
    # review_problems mot m probl
    # admin_problems adm m probl
    # problem all, no_problem,only_problem
    #
    # image_id (text)
    ipac_image_id = params[:ipac_image_id] || ''
    sortfield = params[:sortfield] || 'created_at'
    sortdir = params[:sortdir] || 'DESC'

    problem = params[:problem] || 'all'

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
    end

    #@cards = @cards.where.not(tertiary_registrator_end: nil) if level == ''

    @cards = @cards.order(sortfield)
    @cards = @cards.reverse_order if sortdir.upcase == 'DESC'

    pagination[:pages] = @cards.total_pages
    pagination[:page] = @cards.current_page
    pagination[:next] = @cards.next_page
    pagination[:previous] = @cards.previous_page

    query[:total] = @cards.total_entries

    render json: {cards: @cards, meta: {pagination: pagination, query: query}}, status: 200
  end

  def show
    username = @current_user.username

    registration_type = params[:registration_type]

    if registration_type == "primary"
      # Find card for primary registration
      card = Card.where("primary_registrator_start IS NULL OR (now() > primary_registrator_start + interval '1' day)").where(primary_registrator_end: nil).order(:ipac_image_id).first
      if card && !card.update_attributes(primary_registrator_username: username, primary_registrator_start: Time.now)
        error_msg(ErrorCodes::VALIDATION_ERROR, "Could not update card", card.errors)
        render_json
        return
      end
    end

    if registration_type == "secondary"
      # Find card for primary registration
      cards = Card.where.not(primary_registrator_username: username).where.not(primary_registrator_end: nil).where("secondary_registrator_start IS NULL OR (now() > secondary_registrator_start + interval '1' day)").where(secondary_registrator_end: nil).order(:ipac_image_id)
      card = cards.first
      if card && !card.update_attributes(secondary_registrator_username: username, secondary_registrator_start: Time.now)
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

        if registration_type == "secondary"
          if !card.update_attributes({secondary_registrator_values: card.registrator_json,
                                 secondary_registrator_problem: card_params[:secondary_registrator_problem],
                                 secondary_registrator_end: Time.now})
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
