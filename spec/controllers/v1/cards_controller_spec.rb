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
        expect(json['card']['primary_registrator_username']).to eq user.username
        expect(json['card']['primary_registrator_start']).to_not be nil
      end
    end
  end

  describe "update" do
    context "for a primary valid card" do
      it "should return card" do
        user = create(:user)
        card = create(:primary_started_card, primary_registrator_username: user.username, title: 'testtitle', primary_registrator_problem: 'Problemtext')

        put :update, id: card.id, card: card.as_json.merge({registration_type: 'primary'}), token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['primary_registrator_end']).to_not be nil
        expect(json['card']['primary_registrator_values']['title']).to eq 'testtitle'
        expect(json['card']['primary_registrator_problem']).to eq 'Problemtext'
        
      end
    end

    context "for a primary valid card with wrong user" do
      it "should return an error code" do
        user1 = create(:user)
        user2 = create(:user)
        card = create(:primary_started_card, primary_registrator_username: user1.username)

        put :update, id: card.id, card: card.as_json.merge({registration_type: 'primary'}), token: user2.valid_tokens.first

        expect(response.status).to eq 404
        expect(json['card']).to be nil
      end
    end
  end
end