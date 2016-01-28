require 'rails_helper'

RSpec.describe V1::CardsController, :type => :controller do

  describe "show" do
    context "for primary registration with cards" do
      it "should return a card for registration" do
        user = create(:user)
        card = create(:not_started_card)

        get :show, registration_type: "primary", username: user.username

        expect(json['card']).to_not be nil
        expect(json['card']['id']).to eq card.id
        expect(json['card']['primary_registator_username']).to eq user.username
        expect(json['card']['primary_registrator_start']).to_not be nil
      end
    end
  end
end
