require 'rails_helper'

RSpec.describe V1::UsersController, :type => :controller do
  before :each do
    api_users = APP_CONFIG['api_key_users']
    @test_api_key = api_users.find { |user| user['username'] == 'test_key_user'}['api_key']
    @test_admin_api_key = api_users.find { |user| user['username'] == 'test_admin_key_user'}['api_key']
  end

  describe "index" do
    context "for existing users" do
      it "should return a list of users" do
        create_list(:user, 3)

        get :index, api_key: @test_admin_api_key

        expect(json['users'].count).to eq 3
      end
    end
  end

  describe "create" do
    context "without access key or token for ADMIN user" do
      it "should fail with 403" do
        post :create, user: {username: 'testuser', password: 'secret', role: 'OPER'}

        expect(response.status).to eq(403)
      end
    end
    context "for valid parameters" do
      it "should create a user" do
        post :create, user: {username: 'testuser', password: 'secret', role: 'OPER'}, api_key: @test_admin_api_key

        expect(response.status).to eq 201
        expect(json['user']['username']).to eq 'testuser'
      end
    end

    context "for invalid parameters" do
      it "should return an error message" do
        post :create, user: {username: 'testuser', password: 'secret'}, api_key: @test_admin_api_key

        expect(response.status).to eq 422
        expect(json['user']).to eq nil
      end
    end
  end

  describe "statistics" do
    before :each do
      @oper_1 = create(:user, username: 'pelle', password: 'pelle', role: 'OPER')
      @oper_2 = create(:user, username: 'olle', password: 'olle', role: 'OPER')
      @admin = create(:admin_user)
    end
    context "OPER user" do
      it "should get correct user statistic values" do
        card = create(:primary_started_card, primary_registrator_username: @oper_1.username, title: 'asdfasdf', primary_registrator_end: Time.now)

        get :statistics, id: @oper_1.username, token: @oper_1.valid_tokens.first

        expect(response.status).to eq 200
        expect(json['user']['statistics']).to_not be nil
        expect(json['user']['statistics']['primary_registered_card_count']).to_not be nil
        expect(json['user']['statistics']['secondary_registered_card_count']).to_not be nil
        expect(json['user']['statistics']['available_for_secondary_registration_count']).to_not be nil
      end
      it "should not get statistics for admin users only" do
        get :statistics, id: @oper_1.username, token: @oper_1.valid_tokens.first
        expect(json['user']['statistics']['admin_statistics']).to be nil
      end
    end
    context "ADMIN user" do
      it "should get statistics only available for admin users" do
        get :statistics, id: @admin.username, token: @admin.valid_tokens.first
        expect(json['user']['statistics']['totals']).to_not be nil
      end

      context "looking for totals" do
        before :each do
          cards = create_list(:not_started_card, 40)
          cards += create_list(:primary_ended_card, 30)
          cards += create_list(:secondary_ended_card, 20)
          cards += create_list(:tertiary_ended_card, 10)
        end

        it "should get total number of cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['card_count']).to_not be nil
          expect(json['user']['statistics']['totals']['card_count']).to eq(100)
        end

        it "should get total number of indexed cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['primary_ended_card_count']).to eq(30)
        end

        it "should get total number of reviewed cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['secondary_ended_card_count']).to eq(20)
        end

        it "should get total number of admin viewed cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['tertiary_ended_card_count']).to eq(10)
        end

        it "should get total number of not started cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['not_started_card_count']).to eq(40)
        end
      end

      context "looking for card type totals" do
        before :each do
          cards = create_list(:card, 30, card_type: 'main')
          cards += create_list(:card, 20, card_type: 'reference')
          cards += create_list(:card, 10, card_type: 'pseudonym')
        end

        it "should get total number of main cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['main_card_count']).to eq(30)
        end

        it "should get total number of reference cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['reference_card_count']).to eq(20)
        end

        it "should get total number of pseudonym cards" do
          get :statistics, id: @admin.username, token: @admin.valid_tokens.first
          expect(json['user']['statistics']['totals']['pseudonym_card_count']).to eq(10)
        end
      end

    end
  end
end
