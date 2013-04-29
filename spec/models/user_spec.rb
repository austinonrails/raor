require 'spec_helper'
require "cancan/matchers"
require 'omniauth/auth_hash'

describe User do
  context "fields" do
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:current_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:current_sign_in_ip).of_type(:string) }
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:employer).of_type(:string) }
    it { should have_db_column(:last_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:last_sign_in_ip).of_type(:string) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:remember_created_at).of_type(:datetime) }
    it { should have_db_column(:remember_employer).of_type(:boolean) }
    it { should have_db_column(:sign_in_count).of_type(:integer) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context "mass-assignment" do
    context "user" do
      it { should allow_mass_assignment_of(:api_key).as(:default) }
      it { should allow_mass_assignment_of(:email).as(:default) }
      it { should allow_mass_assignment_of(:employer).as(:default) }
      it { should allow_mass_assignment_of(:name).as(:default) }
      it { should allow_mass_assignment_of(:provider).as(:default) }
      it { should allow_mass_assignment_of(:remember_employer).as(:default) }
      it { should allow_mass_assignment_of(:remember_me).as(:default) }
      it { should allow_mass_assignment_of(:roles).as(:default) }
      it { should allow_mass_assignment_of(:user).as(:default) }
      it { should allow_mass_assignment_of(:uid).as(:default) }
      it { should allow_mass_assignment_of(:user_tokens_attributes).as(:default) }
    end

    context "admin" do
      it { should allow_mass_assignment_of(:created_at).as(:admin) }
      it { should allow_mass_assignment_of(:current_sign_in_at).as(:admin) }
      it { should allow_mass_assignment_of(:current_sign_in_ip).as(:admin) }
      it { should allow_mass_assignment_of(:email).as(:admin) }
      it { should allow_mass_assignment_of(:employer).as(:admin) }
      it { should allow_mass_assignment_of(:id).as(:admin) }
      it { should allow_mass_assignment_of(:last_sign_in_at).as(:admin) }
      it { should allow_mass_assignment_of(:last_sign_in_ip).as(:admin) }
      it { should allow_mass_assignment_of(:name).as(:admin) }
      it { should allow_mass_assignment_of(:remember_created_at).as(:admin) }
      it { should allow_mass_assignment_of(:remember_employer).as(:admin) }
      it { should allow_mass_assignment_of(:sign_in_count).as(:admin) }
      it { should allow_mass_assignment_of(:updated_at).as(:admin) }
      it { should allow_mass_assignment_of(:user_tokens_attributes).as(:admin) }
    end
  end

  context "relations" do
    it { should have_many(:checkins) }
    it { should have_many(:events).through(:checkins) }
    it { should have_many(:user_tokens) }
    it { should accept_nested_attributes_for(:user_tokens) }
  end

  context "validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Aa0_ ').for(:name) }
    it { should_not allow_value('!').for(:name) }
    it { should ensure_length_of(:name).is_at_least(2) }
    it { should ensure_length_of(:name).is_at_most(254) }
    # Bug in shoulda matchers
    #it { should ensure_inclusion_of(:remember_employer).in_array([true, false]) }
  end

  describe "abilities" do
    subject { ability }
    let(:ability){ Ability.new(user) }
    let(:user){ nil }
    let(:another_user){ FactoryGirl.create(:user) }
    let(:event) do
      Timecop.freeze(2.hours.ago) do
        FactoryGirl.create(:event)
      end
    end

    context "when is an admin" do
      let(:user){ FactoryGirl.create(:admin) }

      it{ should be_able_to(:manage, FactoryGirl.build(:checkin)) }
      it{ should be_able_to(:manage, FactoryGirl.build(:event)) }
      it{ should be_able_to(:manage, FactoryGirl.build(:user)) }
      it{ should be_able_to(:manage, FactoryGirl.build(:user_token)) }
    end

    context "when is a moderator" do
      let(:user){ FactoryGirl.create(:moderator) }

      it{ should be_able_to(:read, FactoryGirl.build(:event)) }
      it{ should be_able_to(:manage, FactoryGirl.build(:event, creator: user)) }
      it{ should_not be_able_to(:manage, FactoryGirl.build(:event)) }

      it{ should be_able_to(:manage, user) }
      it{ should_not be_able_to(:manage, another_user) }

      it{ should be_able_to(:manage, FactoryGirl.build(:user_token, user: user)) }
      it{ should_not be_able_to(:manage, FactoryGirl.build(:user_token, user: another_user)) }

      it{ should be_able_to(:read, FactoryGirl.build(:checkin)) }
      it{ should be_able_to(:create, FactoryGirl.build(:checkin, event: event, current_user: user, user: user)) }
      it{ should_not be_able_to(:create, FactoryGirl.build(:checkin, event: event, current_user: user, user: another_user)) }
      it{ should be_able_to(:update, FactoryGirl.build(:checkin, event: event, current_user: user, user: user)) }
      it{ should_not be_able_to(:update, FactoryGirl.build(:checkin, event: event, current_user: another_user, user: another_user)) }
      it{ should be_able_to(:destroy, FactoryGirl.build(:checkin, event: event, current_user: user, user: user)) }
      it{ should_not be_able_to(:destroy, FactoryGirl.build(:checkin, event: event, current_user: another_user, user: another_user)) }
    end

    context "when is a user" do
      let(:user){ FactoryGirl.create(:user) }

      it{ should be_able_to(:read, FactoryGirl.build(:event)) }
      it{ should_not be_able_to(:manage, FactoryGirl.build(:event, creator: user)) }
      it{ should_not be_able_to(:manage, FactoryGirl.build(:event)) }

      it{ should be_able_to(:manage, user) }
      it{ should_not be_able_to(:manage, another_user) }

      it{ should be_able_to(:manage, FactoryGirl.build(:user_token, user: user)) }
      it{ should_not be_able_to(:manage, FactoryGirl.build(:user_token, user: another_user)) }

      it{ should be_able_to(:read, FactoryGirl.build(:checkin)) }
      it{ should be_able_to(:create, FactoryGirl.build(:checkin, event: event, current_user: user, user: user)) }
      it{ should_not be_able_to(:create, FactoryGirl.build(:checkin, event: event, current_user: user, user: another_user)) }
      it{ should be_able_to(:update, FactoryGirl.build(:checkin, event: event, current_user: user, user: user)) }
      it{ should_not be_able_to(:update, FactoryGirl.build(:checkin, event: event, current_user: another_user, user: another_user)) }
      it{ should be_able_to(:destroy, FactoryGirl.build(:checkin, event: event, current_user: user, user: user)) }
      it{ should_not be_able_to(:destroy, FactoryGirl.build(:checkin, event: event, current_user: another_user, user: another_user)) }
    end

    context "when is a banned user" do
      let(:user){ FactoryGirl.create(:banned) }

      it{ should_not be_able_to(:read, FactoryGirl.build(:checkin)) }
      it{ should_not be_able_to(:create, FactoryGirl.build(:checkin)) }
      it{ should_not be_able_to(:update, FactoryGirl.build(:checkin)) }
      it{ should_not be_able_to(:destroy, FactoryGirl.build(:checkin)) }

      it{ should_not be_able_to(:read, FactoryGirl.build(:event)) }
      it{ should_not be_able_to(:create, FactoryGirl.build(:event)) }
      it{ should_not be_able_to(:update, FactoryGirl.build(:event)) }
      it{ should_not be_able_to(:destroy, FactoryGirl.build(:event)) }

      it{ should_not be_able_to(:read, FactoryGirl.build(:user)) }
      it{ should_not be_able_to(:create, FactoryGirl.build(:user)) }
      it{ should_not be_able_to(:update, FactoryGirl.build(:user)) }
      it{ should_not be_able_to(:destroy, FactoryGirl.build(:user)) }

      it{ should_not be_able_to(:read, FactoryGirl.build(:user_token)) }
      it{ should_not be_able_to(:create, FactoryGirl.build(:user_token)) }
      it{ should_not be_able_to(:update, FactoryGirl.build(:user_token)) }
      it{ should_not be_able_to(:destroy, FactoryGirl.build(:user_token)) }
    end
  end

  context "devise" do
    it { should have_module(Devise::Models::DatabaseAuthenticatable) }
    it { should have_module(Devise::Models::Rememberable) }
    it { should have_module(Devise::Models::Trackable) }
    it { should have_module(Devise::Models::Validatable) }
    it { should have_module(Devise::Models::Omniauthable) }

    it "should not require a password" do
      subject.send(:password_required?).should be_false
    end

    it "should not require email" do
      subject.send(:email_required?).should be_false
    end
  end

  context "roles" do
    before(:each) do
      @roles = %w[admin moderator author banned]
      @user = FactoryGirl.create(:user, :roles => @roles)
    end

    it "should have a ROLES constant" do
      described_class::ROLES.should == @roles
    end

    it "should assign roles" do
      @user.roles.should == @roles
    end

    described_class::ROLES.each do |role|
      it "should be a #{role}" do
        @user.is?(role).should be_true
      end
    end
  end

  context "oauth" do
    ['twitter', 'facebook', 'github', 'open_id'].each do |provider|
      context provider do
        before(:each) do
          @name = 'User'
          @provider = provider
          @uid = '1'
          @email = 'user@example.com'

          @omniauth = OmniAuth::AuthHash.new({
            provider: @provider,
            uid: @uid,
            info: OmniAuth::AuthHash::InfoHash.new({
              email: @email,
              nickname: @name,
              name: @name,
              location: 'Austin, TX',
              image: nil,
              description: nil,
              urls: OmniAuth::AuthHash.new({
                Website: nil,
                Twitter: nil
              })
            }),
            extra: OmniAuth::AuthHash.new({
              screen_name: @name
            })
          })
        end

        context "when creating user and token" do
          subject { lambda { described_class.send("find_for_#{provider}_oauth".to_sym, @omniauth) } }

          it { should change(described_class, :count).from(0).to(1) }
          it { should change(UserToken, :count).from(0).to(1) }

          it "should create the correct UserToken" do
            subject.call.should == UserToken.where(provider: @provider, uid: @uid, user_id: subject.call.id).first.user
          end

          it "should create the correct #{described_class}" do
            subject.call.should == described_class.where(name: @name).first
          end
        end

        context "when creating just a user" do
          before(:each) do
            UserToken.create!(provider: @provider, uid: @uid)
          end

          subject { lambda { described_class.send("find_for_#{provider}_oauth".to_sym, @omniauth) } }

          it { should change(described_class, :count).from(0).to(1) }
          it { should_not change(UserToken, :count) }

          it "should create the correct #{described_class}" do
            subject.call.should == described_class.where(name: @name).first
          end
        end

        context "when user and token exist" do
          before(:each) do
            @user = FactoryGirl.create(:user, name: @name, email: @email)
            FactoryGirl.create(:user_token, provider: @provider, uid: @uid, user: @user)
          end

          subject { lambda { described_class.send("find_for_#{provider}_oauth".to_sym, @omniauth) } }

          it { should_not change(described_class, :count) }
          it { should_not change(UserToken, :count) }

          it "should find user" do
            subject.call.should == @user
          end
        end
      end
    end
  end
end