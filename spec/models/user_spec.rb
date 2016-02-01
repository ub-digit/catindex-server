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

  describe "user statistics" do
    before :each do
      @operator_1 = create(:user, username: 'pelle', password: 'pelle', role: 'OPER')
      @operator_2 = create(:user, username: 'olle', password: 'olle', role: 'OPER')
      @operator_3 = create(:user, username: 'kalle', password: 'kalle', role: 'OPER')
    end
    context "count primary registered cards" do
      it "should return the number the user has primary registered cards" do
        create_list(:primary_ended_card, 7, primary_registrator_username: @operator_1.username)
        expect(@operator_1.primary_registered_card_count).to eq(7)
      end
      it "should return zero if the user has no primary registered cards" do
        expect(@operator_1.primary_registered_card_count).to eq(0)
      end
    end
    context "count secondary registered cards" do
      it "should return the number if the user has secondary registered cards" do
        create_list(:secondary_ended_card, 5, secondary_registrator_username: @operator_1.username)
        expect(@operator_1.secondary_registered_card_count).to eq(5)
      end
      it "should return zero if the user has only an ongoing secondary registration card" do
        create(:secondary_started_card, secondary_registrator_username: @operator_1.username)
        expect(@operator_1.secondary_registered_card_count).to eq(0)
      end
    end
    context "count cards available for secondary registration" do
      it "should return number if secondary registration never starded" do
        create_list(:primary_ended_card, 2, primary_registrator_username: @operator_1.username)
        expect(@operator_2.available_for_secondary_registration_count).to eq(2)
      end

      it "should return number if secondary registration is started but not finished before expiration" do
        create_list(:card, 2, primary_registrator_end: 3.days.ago,
            primary_registrator_username: @operator_1.username,
            secondary_registrator_end: nil,
            secondary_registrator_start: 2.days.ago,
            secondary_registrator_username: @operator_2.username)
        expect(@operator_3.available_for_secondary_registration_count).to eq(2)
      end

      it "should return zero if there are only finished secondary registrations" do
        create_list(:primary_started_card, 3, primary_registrator_username: @operator_1.username, secondary_registrator_end: @now, secondary_registrator_username: @operator_2.username)
        expect(@operator_3.available_for_secondary_registration_count).to eq(0)
      end

      it "should return zero if there are no cards" do
        expect(@operator_3.available_for_secondary_registration_count).to eq(0)
      end

    end
  end
end
