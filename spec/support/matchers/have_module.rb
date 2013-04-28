RSpec::Matchers.define :have_module do |const|
  match do |owner|
    owner.class.included_modules.include?(const)
  end
end