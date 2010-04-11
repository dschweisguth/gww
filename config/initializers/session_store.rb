# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gww_session',
  :secret      => '52fb5dd4775abfe0e5cfd00eedd6bc30aee977b5e02dec2933bd16c2f2aad38395ddbe989342c6bcd4a789866a64f41d78f2d89681b3cb2e171afef8f3cab111'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
