require 'rails_helper'

RSpec.describe Card, :type => :model do
  context "lookup value hint" do
    it "should fetch lookup value from previously indexed card" do
      create(:primary_ended_card, ipac_image_id: 1, lookup_field_value: "test lookup 1")
      create(:primary_started_card, ipac_image_id: 2)
      card = Card.find_by_ipac_image_id(2)
      expect(card.previous_card_lookup_value).to eq("test lookup 1")
    end
  end
end
