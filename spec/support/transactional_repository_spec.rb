RSpec.configure do |config|
  db = Sequel::Model.db

  %i[repository service].each do |type|
    config.around(:each, type: type) do |example|
      db.transaction(rollback: :always, auto_savepoint: true) do
        example.run
      end
    end
  end
end
