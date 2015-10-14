require 'ethereum'
require 'pry'
require_relative 'lib/project'


task :default do
  puts "This is the default task"
end

namespace :contracts do

  desc "Deploy all contracts to blockchain"
  task :deploy do
    project = Project.new
    project.deploy
  end
  
  desc "Test all contracts"
  task :test do
    system("bin/rspec spec/01_digibot_configuration_spec.rb")
    system("bin/rspec spec/02_digixbot_users_spec.rb")
    system("bin/rspec spec/03_digixbot_ethereum_spec.rb")
    system("bin/rspec spec/04_digixbot_spec.rb")
  end

  desc "Access the Digixbot console"
  task :console do
    require 'irb'
    @project = Project.new
    @project.init("deployment.yml")
    ARGV.clear
    IRB.start
  end
end
