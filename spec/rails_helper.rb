# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require 'rspec/rails'
require 'factory_bot_rails'

# Explicitly require rails-controller-testing
require 'rails/controller/testing'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', '**', '*.rb')].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-1/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Use the newer `:controller` syntax for controller specs
  config.before(:each, type: :controller) do
    @routes = Rails.application.routes
  end

  # Include FactoryBot syntax
  config.include FactoryBot::Syntax::Methods

  # Include Devise test helpers for controller specs
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Include Devise test helpers for request specs
  config.include Devise::Test::IntegrationHelpers, type: :request

  # For System Specs using Devise
  config.include Warden::Test::Helpers, type: :system

  # Include the rails-controller-testing helpers
  config.include Rails::Controller::Testing::TestProcess, type: :controller
  config.include Rails::Controller::Testing::TemplateAssertions, type: :controller
  config.include Rails::Controller::Testing::Integration, type: :controller
end

# Explicitly require rails-controller-testing for the assigns method
# require 'rails/controller/testing/assigns' # Commenting this out

# Monkey patch to fix FrozenError with eager_load and autoload_paths
# This should only be needed if you are modifying load paths directly in initializers
# or if there's a gem conflict.
# If the FrozenError persists, this monkey patch might indicate a deeper configuration issue
# that needs to be addressed by fixing the underlying cause.
# Rails.configuration.autoload_paths = Rails.configuration.autoload_paths.dup.freeze unless Rails.env.test?
# Rails.configuration.eager_load_paths = Rails.configuration.eager_load_paths.dup.freeze unless Rails.env.test?

# Monkey patch for ArgumentError with enum in Rails 8.0.1
# This is a known issue in Rails 8.0.1 that affects how enums are initialized
# during test environment loading when eager_load is enabled.
# This monkey patch provides a workaround by ensuring the enum is initialized correctly.
# Remove this patch when upgrading to a Rails version that fixes this issue.
#
# To identify if this patch is still needed, check the Rails changelog for fixes
# related to enum loading with eager_load in the test environment.
#
# unless defined?(Rails::VERSION::STRING) && Rails::VERSION::STRING >= '8.0.2'
#   module ActiveRecord
#     module Enum
#       class Map
#         def initialize(enum_method_name, values, model)
#           @enum_method_name = enum_method_name
#           @values = values
#           @model = model
#         end
#       end
#     end
#   end
# end
