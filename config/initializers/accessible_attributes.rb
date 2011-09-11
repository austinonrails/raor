class ActiveRecord::Base
  include ActiveModel::MassAssignmentSecurity

  def assign_attributes(values, options = {})
    sanitize_for_mass_assignment(values, options[:as] || :default).each do |k, v|
      send("#{k}=", v)
    end
  end
end
