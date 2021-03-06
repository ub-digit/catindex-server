class Card < ActiveRecord::Base

  # Generates json document stored per registration time
  def registrator_json
    {
      card_type: card_type,
      classification: classification,
      collection: collection,
      lookup_field_value: lookup_field_value,
      lookup_field_type: lookup_field_type,
      title: title,
      year_from: year_from,
      year_to: year_to,
      no_year: no_year,
      additional_authors: additional_authors,
      reference_text: reference_text
    }
  end

  def previous_card_lookup_value
    previous_card = Card.where("ipac_image_id < ?", ipac_image_id).
      where.not(primary_registrator_end: nil).
      where.not(lookup_field_value: nil).
      where.not(lookup_field_value: "").
      order(:ipac_image_id).reverse_order.first
    if previous_card
      return previous_card.lookup_field_value
    else
      return nil
    end
  end

  def self.sample_card
    sample_selection_count = Card.where.not(secondary_registrator_end: nil).
      where(tertiary_registrator_end: nil).
      where(secondary_registrator_problem: "").count
    sample_query = <<-SQL
SELECT * FROM cards
 WHERE secondary_registrator_end IS NOT NULL
 AND tertiary_registrator_end IS NULL
 AND secondary_registrator_problem = ''
 OFFSET FLOOR(RANDOM()*#{sample_selection_count})
 LIMIT 1
    SQL
    Card.find_by_sql(sample_query).first
  end

  def self.admin_problems(cards = Card)
    cards.where.not(tertiary_registrator_end: nil).where.not(tertiary_registrator_problem: '')
  end

  def self.review_problems(cards = Card)
    cards.where(tertiary_registrator_end: nil)
          .where.not(secondary_registrator_problem: '')
          .where.not(secondary_registrator_end: nil)
  end

  def self.all_problems(cards = Card)
    cards.where("id in (?) or id in (?)", admin_problems.select(:id), review_problems.select(:id))
  end

  # Cards with ipac_lookup data
  def self.indexed_ipac_lookup_cards(cards = Card)
    cards.where.not(ipac_lookup: nil).
      where.not(primary_registrator_end: nil).
      select("*,round(100*levenshtein(ipac_lookup,lookup_field_value)::numeric/levenshtein(ipac_lookup,''),1) as difference")
  end

  # Cards with ipac_lookup data and current lookup_field_value not matching ipac_lookup
  def self.ipac_lookup_cards_with_mismatch(cards = Card)
    indexed_ipac_lookup_cards(cards).where("ipac_lookup != lookup_field_value").
      where.not(lookup_field_value: nil)
  end

  def self.card_count
    Card.all.count
  end

  def self.not_started_card_count
    Card.where(primary_registrator_end: nil).count
  end

  def self.primary_ended_card_count
    Card.where.not(primary_registrator_end: nil).where(secondary_registrator_end: nil).count
  end

  def self.secondary_ended_card_count
    Card.where.not(secondary_registrator_end: nil).where(tertiary_registrator_end: nil).count
  end

  def self.tertiary_ended_card_count
    Card.where.not(tertiary_registrator_end: nil).count
  end

  def self.main_card_count
    Card.where(card_type: 'main').count
  end

  def self.reference_card_count
    Card.where(card_type: 'reference').count
  end

  def self.pseudonym_card_count
    Card.where(card_type: 'pseudonym').count
  end

  def self.primary_ended_average_time
    time = Card.where.not(primary_registrator_end: nil).
      where("primary_registrator_end-primary_registrator_start < '15 minutes'::interval").
      select("avg(primary_registrator_end-primary_registrator_start) as average").order("average").first
    return nil if !time || !time.average
    interval = Time.parse(time.average) - Time.parse("00:00:00")
    return (1000*interval).to_i
  end

  def self.secondary_ended_average_time
    time = Card.where.not(secondary_registrator_end: nil).
      where("secondary_registrator_end-secondary_registrator_start < '15 minutes'::interval").
      select("avg(secondary_registrator_end-secondary_registrator_start) as average").order("average").first
    return nil if !time || !time.average
    interval = Time.parse(time.average) - Time.parse("00:00:00")
    return (1000*interval).to_i
  end

end
