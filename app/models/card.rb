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
end
