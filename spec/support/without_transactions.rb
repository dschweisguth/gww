def without_transactions

  before(:all) do
    ActiveSupport::TestCase.use_transactional_fixtures = false
  end

  after(:all) do
    ActiveSupport::TestCase.use_transactional_fixtures = true
  end

end
