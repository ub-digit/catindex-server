require 'rails_helper'

RSpec.describe V1::CardsController, :type => :controller do
  before :each do
    api_users = APP_CONFIG['api_key_users']
    @test_api_key = api_users.find { |user| user['username'] == 'test_key_user'}['api_key']
    @test_admin_api_key = api_users.find { |user| user['username'] == 'test_admin_key_user'}['api_key']
    @admin_user = create(:admin_user)
  end

  describe "index" do
    context "without credentials, access token or key" do
      it "should fail with 403" do
        cards = create_list(:card, 10)

        get :index

        expect(response.status).to eq(403)
      end
    end
    context "with no filters" do
      it "should return a list with all cards" do
        cards = create_list(:card, 10)
        get :index, token: @admin_user.valid_tokens.first

        expect(json['cards']).to_not be nil
        expect(json['cards'].count).to eq(10)
      end
    end

    context "with problem filter" do
      before :each do
        cards = create_list(:not_started_card, 7)
        cards += create_list(:primary_ended_card, 6)
        cards += create_list(:secondary_ended_card, 5)
        cards += create_list(:tertiary_ended_card, 4)
        cards += create_list(:primary_problem_card, 3)
        cards += create_list(:secondary_problem_card, 2)
        cards += create_list(:tertiary_problem_card, 1)
      end
      context "with review_problems filter" do
        it "should return a list of reviewed cards with problems" do
          get :index, problem: 'review_problems', token: @admin_user.valid_tokens.first
          expect(json['cards'].count).to eq(2)
        end
      end
      context "with admin_problems filter" do
        it "should return a list of admin cards with problems" do
          get :index, problem: 'admin_problems', token: @admin_user.valid_tokens.first
          expect(json['cards'].count).to eq(1)
        end
      end
      context "with all_problems filter" do
        it "should return a list of review and admin cards with problems" do
          get :index, problem: 'all_problems', token: @admin_user.valid_tokens.first
          expect(json['cards'].count).to eq(3)
        end
      end
      context "with all filter" do
        it "should return a list with all cards" do
          get :index, problem: 'all', token: @admin_user.valid_tokens.first
          expect(json['cards'].count).to eq(28)
        end
      end
      context "ipac lookup comparison" do
        before :each do
          create(:primary_ended_card, ipac_lookup: "test lookup", lookup_field_value: "test lookup")
          create(:secondary_ended_card, ipac_lookup: "test another lookup", lookup_field_value: "test another lookup")
          create(:primary_ended_card, ipac_lookup: "test lookup correct", lookup_field_value: "test lookup error")
          create(:secondary_ended_card, ipac_lookup: "test another lookup correct", lookup_field_value: "really bad error")
        end
        context "with indexed_ipac_lookup_cards filter" do
          it "should return a list with indexed cards that have ipac_lookup set" do
            get :index, problem: 'indexed_ipac_lookup_cards', token: @admin_user.valid_tokens.first
            expect(json['cards'].count).to eq(4)
            expect(json['cards'][0]['difference']).to eq("0.0")
            expect(json['cards'][1]['difference']).to eq("0.0")
            expect(json['cards'][2]['difference']).to_not eq("0.0")
            expect(json['cards'][3]['difference']).to_not eq("0.0")
          end
        end
        context "with ipac_lookup_cards_with_mismatch filter" do
          it "should return a list with indexed cards that have ipac_lookup set and differs from current lookup_field_value" do
            get :index, problem: 'ipac_lookup_cards_with_mismatch', token: @admin_user.valid_tokens.first
            expect(json['cards'].count).to eq(2)
            expect(json['cards'][0]['difference']).to_not eq("0.0")
            expect(json['cards'][1]['difference']).to_not eq("0.0")
            expect(json['cards'][1]['difference'].to_f).to be > json['cards'][0]['difference'].to_f
          end
        end
      end
    end

    context "with given image_id" do
      context "if the card exists" do
        it "should return the corresponding card" do
          card = create(:card, ipac_image_id: 12345)
          get :index, image_id: 12345, token: @admin_user.valid_tokens.first
          expect(json['cards'].count).to eq(1)
        end
      end
    end
  end

  describe "show" do
    context "without access token or key" do
      it "should fail with 403" do
        user = create(:user)
        card = create(:not_started_card)

        get :show, identifier: "primary"

        expect(response.status).to eq(403)
      end
    end
    context "for primary registration with cards" do
      it "should return a card for registration" do
        user = create(:user)
        card = create(:not_started_card)

        get :show, identifier: "primary", token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['id']).to eq card.id
        expect(json['card']['primary_registrator_username']).to eq user.username
        expect(json['card']['primary_registrator_start']).to_not be nil
      end
    end
    context "for primary registration with card that is is started two days ago and not ended" do
      it "should return card" do
        old_user = create(:user)
        old_starttime = 2.days.ago
        user = create(:user)
        card = create(:not_started_card)

        card.update_attributes(primary_registrator_start: old_starttime, primary_registrator_username: old_user.username)

        get :show, identifier: "primary", token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['id']).to eq card.id
        expect(json['card']['primary_registrator_username']).to eq user.username
        expect(json['card']['primary_registrator_start']).to_not eq old_starttime
      end
    end
    context "for primary registration with card that is started less than a day ago and not ended" do
      it "should not return card" do
        user = create(:user)
        card = create(:primary_started_card)

        get :show, identifier: "primary", token: user.valid_tokens.first

        expect(json['card']).to be nil
        expect(response.status).to eq 404
      end
    end
    context "for secondaryregistration with cards" do
      it "should return a card for registration" do
        old_user = create(:user)
        user = create(:user)
        card = create(:primary_ended_card, primary_registrator_username: old_user.username)

        get :show, identifier: "secondary", token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['id']).to eq card.id
        expect(json['card']['secondary_registrator_username']).to eq user.username
        expect(json['card']['secondary_registrator_start']).to_not be nil
      end
    end
    context "for secondary registration with card that is is started two days ago and not ended" do
      it "should return card" do
        primary_user = create(:user)
        old_user = create(:user)
        old_starttime = 2.days.ago
        user = create(:user)
        card = create(:primary_ended_card, primary_registrator_username: primary_user.username)

        card.update_attributes(secondary_registrator_start: old_starttime, secondary_registrator_username: old_user.username)

        get :show, identifier: "secondary", token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['id']).to eq card.id
        expect(json['card']['secondary_registrator_username']).to eq user.username
        expect(json['card']['secondary_registrator_start']).to_not eq old_starttime
      end
    end
    context "for secondary registration with card that is started less than a day ago and not ended" do
      it "should not return card" do
        primary_user = create(:user)
        secondary_user = create(:user)
        user = create(:user)
        card = create(:secondary_started_card, primary_registrator_username: primary_user.username, secondary_registrator_username: secondary_user.username)

        get :show, identifier: "secondary", token: user.valid_tokens.first

        expect(json['card']).to be nil
        expect(response.status).to eq 404
      end
    end
    context "for secondary registration when current user did primary registration" do
      it "should not return card" do
        user = create(:user)
        card = create(:primary_ended_card, primary_registrator_username: user.username)

        get :show, identifier: "secondary", token: user.valid_tokens.first

        expect(json['card']).to be nil
        expect(response.status).to eq 404
      end
    end

    context "for admin user" do
      it "should return card if image_id exists" do
        card = create(:card, ipac_image_id: 12345)

        get :show, identifier: 12345, token: @admin_user.valid_tokens.first
        expect(response.status).to eq(200)
        expect(json['card']).to_not be nil
      end
      it "should return error if card does not exist" do
        get :show, identifier: 12345, token: @admin_user.valid_tokens.first
        expect(response.status).to eq(404)
        expect(json['card']).to be nil
        expect(json['error']['msg']).to eq('Could not find a card')
      end
      it "should return error if identifier is incorrect" do
        get :show, identifier: 'tjottabengtsson', token: @admin_user.valid_tokens.first
        expect(response.status).to eq(404)
        expect(json['card']).to be nil
        expect(json['error']['msg']).to eq('Could not find a card')
      end
      it "should return card if user is admin user" do
        card = create(:card, ipac_image_id: 12345)
        get :show, identifier: 12345, token: @admin_user.valid_tokens.first
        expect(response.status).to eq(200)
      end
      it "should return error if user is not admin user" do
        operator = create(:user, username: 'xyzxyz', password: 'xyzxyz', role: 'OPER')
        card = create(:card, ipac_image_id: 12345)
        get :show, identifier: 12345, token: operator.valid_tokens.first
        expect(response.status).to eq(404)
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

    context "for a secondary valid card" do
      it "should return card" do
        user = create(:user)
        card = create(:secondary_started_card, secondary_registrator_username: user.username, title: 'testtitle', secondary_registrator_problem: 'Problemtext')

        put :update, id: card.id, card: card.as_json.merge({registration_type: 'secondary'}), token: user.valid_tokens.first

        expect(json['card']).to_not be nil
        expect(json['card']['secondary_registrator_end']).to_not be nil
        expect(json['card']['secondary_registrator_values']['title']).to eq 'testtitle'
        expect(json['card']['secondary_registrator_problem']).to eq 'Problemtext'

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
