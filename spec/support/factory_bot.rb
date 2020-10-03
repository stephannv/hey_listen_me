RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

FactoryBot.define do
  initialize_with { new(attributes) }
  skip_create
end
