require 'rails_helper'

RSpec.describe V1::CardsController, :type => :controller do
  before :each do
    api_users = APP_CONFIG['api_key_users']
    @test_api_key = api_users.find { |user| user['username'] == 'test_key_user'}['api_key']
    @test_admin_api_key = api_users.find { |user| user['username'] == 'test_admin_key_user'}['api_key']
  end

  describe "show" do
    context "without access token or key" do
      it "should fail with 403" do
        user = create(:user)
        card = create(:not_started_card)

        get :show, registration_type: "primary"
        
        expect(response.status).to eq(403)
      end
    end
    context "for primary registration with cards" do
      it "should return a card for registration" do
        user = create(:user)
        card = create(:not_started_card)

        get :show, registration_type: "primary", token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['id']).to eq card.id
        expect(json['card']['primary_registator_username']).to eq user.username
        expect(json['card']['primary_registrator_start']).to_not be nil
      end
    end
  end
end
