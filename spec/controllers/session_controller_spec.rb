require 'rails_helper'

RSpec.describe SessionController, :type => :controller do
  before :each do
    User.create(username: "admin", password: "admin", role: "ADMIN")
  end
  describe "create session" do
    it "should return access_token on valid credentials" do
      post :create, username: "admin", password: "admin"
      user = User.find_by_username("admin")
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      expect(json['access_token']).to eq(user.access_tokens.first.token)
    end

    it "should return 401 with error on invalid password and invalid user" do
      post :create, username: "invalid_user", password: "invalid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end

    it "should return 401 with error on invalid password for valid user" do
      post :create, username: "admin", password: "invalid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end

    it "should return user data on valid credentials" do
      post :create, username: "admin", password: "admin"
      user = User.find_by_username("admin")
      expect(json['user']['username']).to eq(user.username)
    end

    it "should allow the same user to login multiple times, getting different tokens" do
      post :create, username: "admin", password: "admin"
      token1 = json['access_token']
      post :create, username: "admin", password: "admin"
      token2 = json['access_token']
      get :show, id: token1
      expect(response.status).to eq(200)
      get :show, id: token2
      expect(response.status).to eq(200)
    end
  end

end
