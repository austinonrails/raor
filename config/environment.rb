# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Raor::Application.initialize!
WillPaginate.per_page = 25
ActiveSupport.use_standard_json_time_format = false