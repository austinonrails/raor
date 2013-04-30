require 'spec_helper'

describe Checkin do
  context "fields" do
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:employ).of_type(:boolean) }
    it { should have_db_column(:employer).of_type(:string) }
    it { should have_db_column(:employment).of_type(:boolean) }
    it { should have_db_column(:event_id).of_type(:integer) }
    it { should have_db_column(:hidden).of_type(:boolean) }
    it { should have_db_column(:rafflr).of_type(:boolean) }
    it { should have_db_column(:shoutout).of_type(:string) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_accessor(:current_user) }
    it { should have_accessor(:remember_employer) }
  end

  context "mass-assignment" do
    context "user" do
      it { should allow_mass_assignment_of(:employ).as(:default) }
      it { should allow_mass_assignment_of(:employer).as(:default) }
      it { should allow_mass_assignment_of(:employment).as(:default) }
      it { should allow_mass_assignment_of(:event_id).as(:default) }
      it { should allow_mass_assignment_of(:rafflr).as(:default) }
      it { should allow_mass_assignment_of(:remember_employer).as(:default) }
      it { should allow_mass_assignment_of(:shoutout).as(:default) }
      it { should allow_mass_assignment_of(:user_id).as(:default) }
    end

    context "admin" do
      it { should allow_mass_assignment_of(:created_at).as(:admin) }
      it { should allow_mass_assignment_of(:employ).as(:admin) }
      it { should allow_mass_assignment_of(:employer).as(:admin) }
      it { should allow_mass_assignment_of(:employment).as(:admin) }
      it { should allow_mass_assignment_of(:event_id).as(:admin) }
      it { should allow_mass_assignment_of(:hidden).as(:admin) }
      it { should allow_mass_assignment_of(:rafflr).as(:admin) }
      it { should allow_mass_assignment_of(:remember_employer).as(:admin) }
      it { should allow_mass_assignment_of(:shoutout).as(:admin) }
      it { should allow_mass_assignment_of(:updated_at).as(:admin) }
      it { should allow_mass_assignment_of(:user_id).as(:admin) }
    end
  end

  context "callbacks" do
    it "should receive set_employer on create" do
      described_class.any_instance.should_receive(:set_employer)
      FactoryGirl.create(:checkin)
    end

    it "should not receive set_employer on new" do
      described_class.any_instance.should_not_receive(:set_employer)
      FactoryGirl.build(:checkin)
    end

    it "should receive set_employer on save" do
      checkin = FactoryGirl.build(:checkin)
      checkin.should_receive(:set_employer)
      checkin.save
    end
  end

  context "validations" do
    # Bug in shoulda matchers
    #it { should ensure_inclusion_of(:employ).in_array([true, false]) }
    #it { should ensure_inclusion_of(:employment).in_array([true, false]) }
    #it { should ensure_inclusion_of(:rafflr).in_array([true, false]) }
    it { should ensure_inclusion_of(:remember_employer).in_array([true, false, "1", "0", 1, 0]) }

    it { should allow_value('Aa0_ !').for(:employer) }
    it { should_not allow_value("\x19").for(:employer) }
    it { should_not allow_value("\x7F").for(:employer) }
    it { should ensure_length_of(:employer).is_at_most(254) }

    it { should allow_value('Aa0_ !').for(:shoutout) }
    it { should_not allow_value("\x19").for(:shoutout) }
    it { should_not allow_value("\x7F").for(:shoutout) }
    it { should ensure_length_of(:shoutout).is_at_most(254) }

    context "is_user" do
      it "should not be valid if no current_user" do
        checkin = FactoryGirl.build(:checkin)
        checkin.current_user = nil
        checkin.valid?
        checkin.errors.messages[:base].should include('Attempting to checkin as another user is a no-no!')
      end

      it "should not be valid if current_user doesn't match user" do
        checkin = FactoryGirl.build(:checkin, current_user: FactoryGirl.create(:user))
        checkin.valid?
        checkin.errors.messages[:base].should include('Attempting to checkin as another user is a no-no!')
      end

      it "should be valid if current_user matches user" do
        user = FactoryGirl.create(:user)
        checkin = FactoryGirl.build(:checkin, current_user: user, user: user)
        checkin.valid?
        checkin.errors.messages.should be_empty
      end
    end
  end

  context "scopes" do
    it "should show hidden" do
      checkin = FactoryGirl.create(:checkin, hidden: true)
      FactoryGirl.create(:checkin, hidden: false)
      Checkin.hidden.should == [checkin]
    end

    it "should show unhidden" do
      FactoryGirl.create(:checkin, hidden: true)
      checkin = FactoryGirl.create(:checkin, hidden: false)
      Checkin.unhidden.should == [checkin]
    end

    it "should show employ" do
      checkin = FactoryGirl.create(:checkin, employ: true)
      FactoryGirl.create(:checkin, employ: false)
      Checkin.employ.should == [checkin]
    end

    it "should show employment" do
      checkin = FactoryGirl.create(:checkin, employment: true)
      FactoryGirl.create(:checkin, employment: false)
      Checkin.employment.should == [checkin]
    end

    it "should show rafflr" do
      checkin = FactoryGirl.create(:checkin, rafflr: true)
      FactoryGirl.create(:checkin, rafflr: false)
      Checkin.rafflr.should == [checkin]
    end
  end

  context "set_employer" do
    it "should set employer for logged in user permanently" do
      user = FactoryGirl.create(:user, employer: '')
      employer = 'Employer'
      FactoryGirl.create(:checkin, current_user: user, employer: employer, user: user)
      user.employer.should == employer
    end

    it "should set remember_employer for logged in user permanently" do
      user = FactoryGirl.create(:user, remember_employer: false)
      FactoryGirl.create(:checkin, current_user: user, remember_employer: true, user: user)
      user.employer.should be_true
    end
  end
end