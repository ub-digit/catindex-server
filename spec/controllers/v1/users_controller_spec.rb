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
end
