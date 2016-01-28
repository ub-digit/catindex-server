require 'rails_helper'

RSpec.describe V1::UsersController, :type => :controller do

  describe "index" do
    context "for existing users" do
      it "should return a list of users" do
        create_list(:user, 3)

        get :index

        expect(json['users'].count).to eq 3
      end
    end
  end

  describe "create" do
    context "for valid parameters" do
      it "should create a user" do
        post :create, user: {username: 'testuser', password: 'secret', role: 'OPER'}

        expect(response.status).to eq 201
        expect(json['user']['username']).to eq 'testuser'
      end
    end

    context "for invalid parameters" do
      it "should return an error message" do
        post :create, user: {username: 'testuser', password: 'secret'}

        expect(response.status).to eq 422
        expect(json['user']).to eq nil
      end
    end
  end
end
