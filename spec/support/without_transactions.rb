def without_transactions

  before(:all) do
    # TODO Dave can this be done in RSpec 2?
    #ActiveSupport::TestCase.use_transactional_fixtures = false
  end

  after(:all) do
    #ActiveSupport::TestCase.use_transactional_fixtures = true
  end

end
