require 'rails_helper'

RSpec.describe User, :type => :model do
  describe "create user" do
    context "required fields" do
      it {should validate_presence_of(:username)}
      it {should validate_presence_of(:password)}
      it {should validate_presence_of(:role)}
      it {should validate_uniqueness_of(:username)}
      it {should validate_inclusion_of(:role).in_array(["ADMIN", "OPER"])}
      it {should have_many(:access_tokens)}
    end

    context "password encryption" do
      it "should encrypt passwords for new users before saving" do
        user = User.new(username: "testuser", password: "testpassword", role: "OPER")
        expect(user.password).to eq("testpassword")
        expect(user.save).to be_truthy
        expect(user.password).to_not eq("testpassword")
      end

      it "should not reencrypt passwords for existing users when saving without updating password" do
        user = User.new(username: "testuser", password: "testpassword", role: "OPER")
        user.save
        password_hash = user.password
        user.role = "ADMIN"
        user.save
        expect(user.password).to eq(password_hash)
      end

      it "should reencrypt passwords for existing users when saving with new password set" do
        user = User.new(username: "testuser", password: "testpassword", role: "OPER")
        user.save
        password_hash = user.password
        user.password = "newpassword"
        user.save
        expect(user.password).to_not eq(password_hash)
        expect(user.password).to_not eq("newpassword")
      end
    end
  end

  describe "authentication" do
    context "validate password" do
      it "should return token for correct password" do
        user = User.create(username: "testuser", password: "testpassword", role: "OPER")

        # A token is a random hex string of 32 nibbles
        expect(user.authenticate("testpassword")).to match(/^[0-9a-f]{32}$/)
      end

      it "should give validation error for incorrect password" do
        user = User.create(username: "testuser", password: "testpassword", role: "OPER")
        expect(user.authenticate("wrongpassword")).to be_falsey
      end
    end

    context "validate token" do
      it "should return true if token is valid" do
        user = User.create(username: "testuser", password: "testpassword", role: "OPER")
        user.authenticate("testpassword")
        token = user.access_tokens.first.token
        expect(user.validate_token(token)).to be_truthy
      end

      it "should return true if token is invalid" do
        user = User.create(username: "testuser", password: "testpassword", role: "OPER")
        user.authenticate("testpassword")
        expect(user.validate_token("not-valid-token")).to be_falsey
      end
    end
  end
end
