require 'spec_helper'

describe Event do
  context "mixins" do
    it { described_class.should include(ActionView::Helpers::DateHelper)}
  end

  context "fields" do
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:creator_id).of_type(:integer) }
    it { should have_db_column(:description).of_type(:text) }
    it { should have_db_column(:end_datetime).of_type(:datetime) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:start_datetime).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_accessor(:current_user) }
    it { should have_accessor(:end_date) }
    it { should have_accessor(:end_time) }
    it { should have_accessor(:start_date) }
    it { should have_accessor(:start_time) }

    context "start_datetime" do
      let(:date_format) { '%Y-%m-%d' }
      let(:time_format) { '%H:%M:00' }
      let(:datetime) { Time.zone.now }
      let(:datetime_with_seconds_truncated) { Time.zone.parse(datetime.strftime("#{date_format} #{time_format}")) }
      let(:start_date) { datetime.strftime(date_format) }
      let(:start_time) { datetime.strftime(time_format) }

      it "should set start_datetime" do
        event = FactoryGirl.build(:event, start_date: start_date, start_time: start_time )
        event.start_datetime.should == datetime_with_seconds_truncated
      end

      it "should set start_datetime with date when time already set" do
        new_start_date = (datetime - 1.day).strftime(date_format)
        event = FactoryGirl.build(:event, start_date: start_date, start_time: start_time )
        event.start_date = new_start_date
        event.start_datetime.should == Time.zone.parse("#{new_start_date} #{datetime.strftime(time_format)}")
      end

      it "should set start_datetime with time when date already set" do
        new_start_time = (datetime - 1.hour).strftime(time_format)
        event = FactoryGirl.build(:event, start_date: start_date, start_time: start_time )
        event.start_time = new_start_time
        event.start_datetime.should == Time.zone.parse("#{datetime.strftime(date_format)} #{new_start_time}")
      end
    end

    context "end_datetime" do
      let(:date_format) { '%Y-%m-%d' }
      let(:time_format) { '%H:%M:00' }
      let(:datetime) { Time.zone.now }
      let(:datetime_with_seconds_truncated) { Time.zone.parse(datetime.strftime("#{date_format} #{time_format}")) }
      let(:end_date) { datetime.strftime(date_format) }
      let(:end_time) { datetime.strftime(time_format) }

      it "should set end_datetime" do
        event = FactoryGirl.build(:event, end_date: end_date, end_time: end_time )
        event.end_datetime.should == datetime_with_seconds_truncated
      end

      it "should set end_datetime with date when time already set" do
        new_end_date = (datetime - 1.day).strftime(date_format)
        event = FactoryGirl.build(:event, end_date: end_date, end_time: end_time )
        event.end_date = new_end_date
        event.end_datetime.should == Time.zone.parse("#{new_end_date} #{datetime.strftime(time_format)}")
      end

      it "should set end_datetime with time when date already set" do
        new_end_time = (datetime - 1.hour).strftime(time_format)
        event = FactoryGirl.build(:event, end_date: end_date, end_time: end_time )
        event.end_time = new_end_time
        event.end_datetime.should == Time.zone.parse("#{datetime.strftime(date_format)} #{new_end_time}")
      end
    end
  end

  context "mass-assignment" do
    context "user" do
      it { should allow_mass_assignment_of(:description).as(:default) }
      it { should allow_mass_assignment_of(:end_date).as(:default) }
      it { should allow_mass_assignment_of(:end_time).as(:default) }
      it { should allow_mass_assignment_of(:name).as(:default) }
      it { should allow_mass_assignment_of(:start_date).as(:default) }
      it { should allow_mass_assignment_of(:start_time).as(:default) }
    end

    context "admin" do
      it { should allow_mass_assignment_of(:created_at).as(:admin) }
      it { should allow_mass_assignment_of(:creator_id).as(:admin) }
      it { should allow_mass_assignment_of(:description).as(:admin) }
      it { should allow_mass_assignment_of(:end_date).as(:admin) }
      it { should allow_mass_assignment_of(:end_time).as(:admin) }
      it { should allow_mass_assignment_of(:name).as(:admin) }
      it { should allow_mass_assignment_of(:start_date).as(:admin) }
      it { should allow_mass_assignment_of(:start_time).as(:admin) }
      it { should allow_mass_assignment_of(:updated_at).as(:admin) }
    end
  end

  context "relations" do
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:checkins) }
    it { should have_many(:users).through(:checkins) }
  end

  context "validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Aa0_ ').for(:name) }
    it { should_not allow_value('!').for(:name) }
    it { should ensure_length_of(:name).is_at_least(2) }
    it { should ensure_length_of(:name).is_at_most(254) }

    it { should allow_value('Aa0_ ').for(:description) }
    it { should_not allow_value("\x19").for(:description) }
    it { should_not allow_value("\x7F").for(:description) }
    it { should ensure_length_of(:description).is_at_most(254) }

    it "should start before it ends" do
      Timecop.freeze do
        FactoryGirl.build(:event, end_datetime: 1.second.ago, start_datetime: Time.now).should_not be_valid
        FactoryGirl.build(:event, end_datetime: Time.now, start_datetime: 1.second.ago).should be_valid
      end
    end

    it "should start no more than 5 minutes ago" do
      Timecop.freeze do
        FactoryGirl.build(:event, start_datetime: 5.minutes.ago).should_not be_valid
        FactoryGirl.build(:event, start_datetime: 5.minutes.ago + 1.second).should be_valid
      end
    end
  end

  context "scopes" do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    context "active" do
      it "should start now" do
        event = FactoryGirl.create(:event, start_datetime: Time.zone.now)
        described_class.active.to_a.should include(event)
      end

      it "should start before now" do
        event = FactoryGirl.create(:event, start_datetime: 1.second.ago)
        described_class.active.to_a.should include(event)
      end

      it "should not start after now" do
        event = FactoryGirl.create(:event, start_datetime: 1.second.from_now)
        described_class.active.to_a.should_not include(event)
      end

      it "should end after now" do
        event = FactoryGirl.create(:event, end_datetime: 1.second.from_now)
        described_class.active.to_a.should include(event)
      end

      it "should not end now" do
        event = FactoryGirl.create(:event, start_datetime: 1.minute.ago, end_datetime: Time.zone.now)
        described_class.active.to_a.should_not include(event)
      end

      it "should not end before now" do
        event = FactoryGirl.create(:event, start_datetime: 1.minute.ago, end_datetime: 1.second.ago)
        described_class.active.to_a.should_not include(event)
      end
    end

    context "current" do
      it "should end now" do
        event = FactoryGirl.create(:event, start_datetime: 1.minute.ago, end_datetime: Time.zone.now)
        described_class.current.to_a.should include(event)
      end

      it "should end after now" do
        event = FactoryGirl.create(:event, end_datetime: 1.second.from_now)
        described_class.current.to_a.should include(event)
      end

      it "should not end before now" do
        event = FactoryGirl.create(:event, start_datetime: 1.minute.ago, end_datetime: 1.second.ago)
        described_class.current.to_a.should_not include(event)
      end

      it "should order ascending by end_datetime" do
        event1 = FactoryGirl.create(:event, end_datetime: 2.second.from_now)
        event2 = FactoryGirl.create(:event, end_datetime: 1.seconds.from_now)
        described_class.current.to_a.should == [event2, event1]
      end
    end
  end

  context "active?" do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    it "should start now" do
      FactoryGirl.create(:event, start_datetime: Time.zone.now).active?.should be_true
    end

    it "should start before now" do
      FactoryGirl.create(:event, start_datetime: 1.second.ago).active?.should be_true
    end

    it "should not start after now" do
      FactoryGirl.create(:event, start_datetime: 1.second.from_now).active?.should be_false
    end

    it "should end after now" do
      FactoryGirl.create(:event, end_datetime: 1.second.from_now).active?.should be_true
    end

    it "should not end now" do
      FactoryGirl.create(:event, start_datetime: 1.minute.ago, end_datetime: Time.zone.now).active?.should be_false
    end

    it "should not end before now" do
      FactoryGirl.create(:event, start_datetime: 1.minute.ago, end_datetime: 1.second.ago).active?.should be_false
    end
  end

  context "is_checked_in" do
    context "user" do
      it "is checked in" do
        user = FactoryGirl.create(:user)
        checkin = FactoryGirl.create(:checkin, current_user: user, user: user)
        checkin.event.is_checked_in(user).should be_true
      end

      it "is not checked in" do
        event = FactoryGirl.create(:event)
        user = FactoryGirl.create(:user)
        event.is_checked_in(user).should be_false
      end
    end

    context "current_user" do
      it "is checked in" do
        user = FactoryGirl.create(:user)
        event = FactoryGirl.create(:event, current_user: user)
        FactoryGirl.create(:checkin, current_user: user, event: event, user: user)
        event.is_checked_in(user).should be_true
      end

      it "is not checked in" do
        user = FactoryGirl.create(:user)
        event = FactoryGirl.create(:event, current_user: user)
        event.is_checked_in(user).should be_false
      end
    end
  end

  context "is_in_rafflr" do
    context "user" do
      it "is signed up for rafflr" do
        user = FactoryGirl.create(:user)
        checkin = FactoryGirl.create(:checkin, current_user: user, user: user, rafflr: true)
        checkin.event.is_in_rafflr(user).should be_true
      end

      it "is not signed up for rafflr" do
        user = FactoryGirl.create(:user)
        checkin = FactoryGirl.create(:checkin, current_user: user, user: user, rafflr: false)
        checkin.event.is_in_rafflr(user).should be_false
      end
    end

    context "current_user" do
      it "is signed up for rafflr" do
        user = FactoryGirl.create(:user)
        event = FactoryGirl.create(:event, current_user: user)
        FactoryGirl.create(:checkin, current_user: user, event: event, user: user, rafflr: true)
        event.is_in_rafflr(user).should be_true
      end

      it "is not signed up for rafflr" do
        user = FactoryGirl.create(:user)
        event = FactoryGirl.create(:event, current_user: user)
        FactoryGirl.create(:checkin, current_user: user, event: event, user: user, rafflr: false)
        event.is_in_rafflr(user).should be_false
      end
    end
  end
end