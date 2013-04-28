RSpec::Matchers.define :have_constant do |const|
  match do |owner|
    owner.class.const_defined?(const)
  end
end