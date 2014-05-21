# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Register foreigner's mysql2 adapter as an adapter for mysql2spatial.
# Do this here so that it's done before foreigner's initializer runs (which happens in the next line).
Foreigner::Adapter.register 'mysql2spatial', 'foreigner/connection_adapters/mysql2_adapter'

# Initialize the Rails application.
GWW::Application.initialize!
