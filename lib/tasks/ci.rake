namespace :ci do
  task :config do
    %w(database.yml flickr_credentials.yml).each do |file|
      FileUtils.cp "#{ENV['HOME']}/lib/TeamCity-config/#{file}", 'config'
    end
  end
end
