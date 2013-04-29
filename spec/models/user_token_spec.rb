require 'spec_helper'

describe UserToken do
  context "fields" do
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:provider).of_type(:string) }
    it { should have_db_column(:uid).of_type(:string) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:user_id).of_type(:integer) }
  end

  context "mass-assignment" do
    context "user" do
      it { should allow_mass_assignment_of(:provider).as(:default) }
      it { should allow_mass_assignment_of(:uid).as(:default) }
      it { should allow_mass_assignment_of(:user).as(:default) }
      it { should allow_mass_assignment_of(:user_id).as(:default) }
    end

    context "admin" do
      it { should allow_mass_assignment_of(:created_at).as(:admin) }
      it { should allow_mass_assignment_of(:provider).as(:admin) }
      it { should allow_mass_assignment_of(:uid).as(:admin) }
      it { should allow_mass_assignment_of(:updated_at).as(:admin) }
      it { should allow_mass_assignment_of(:user).as(:admin) }
      it { should allow_mass_assignment_of(:user_id).as(:admin) }
    end
  end

  context "relations" do
    it { should belong_to(:user) }
  end
end