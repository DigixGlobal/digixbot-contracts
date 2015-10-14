require 'ethereum'
require 'pry'
require_relative 'lib/project'


task :default do
  puts "This is the default task"
end

namespace :contracts do

  desc "Deploy all contracts to blockchain"
  task :deploy do
    p = Project.new
    p.deploy
  end
  
  desc "Test all contracts"
  task :test do
    system("bin/rspec spec/01_digibot_configuration_spec.rb")
    system("bin/rspec spec/02_digixbot_users_spec.rb")
    system("bin/rspec spec/03_digixbot_ethereum_spec.rb")
    system("bin/rspec spec/04_digixbot_spec.rb")
  end
end
