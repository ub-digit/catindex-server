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
end
