require 'ethereum'
require 'active_support'
require 'active_support/core_ext'
require 'pry'
require 'colorize'
require 'yaml'

class Project

  CONTRACTS = %w(DigixbotConfiguration DigixbotUsers DigixbotEthereum Digixbot)
  
  CONTRACTS.each do |contract|
    self.send :attr_accessor, contract.underscore.to_sym
  end

  attr_accessor :client, :owner, :formatter, :accounts, :configuration

  def initialize
    @client = Ethereum::HttpClient.new("172.16.135.110", "8545")
    @formatter = Ethereum::Formatter.new
    @owner = @client.coinbase["result"]
    @accounts = @client.accounts["result"].reject {|x| x == @owner }
  end

  def build
    CONTRACTS.each do |contract|
      init = Ethereum::Initializer.new("#{ENV['PWD']}/contracts/#{contract}.sol", @client)
      init.build_all
      send "#{contract.underscore}=".to_sym, contract.constantize.new
    end
  end
  
  def init(yaml_file)
    build
    @configuration = YAML.load_file(yaml_file)
    @owner = @configuration[:owner]
    @digixbot_configuration.as(@owner)
    @digixbot_configuration.at(@configuration[:digixbot_configuration])
    @digixbot_users.as(@owner)
    @digixbot_users.at(@configuration[:digixbot_users])
    @digixbot_ethereum.as(@owner)
    @digixbot_ethereum.at(@configuration[:digixbot_ethereum])
    @digixbot.as(@owner)
    @digixbot.at(@configuration[:digixbot])
  end

  def deploy
    puts "\n"
    puts "     Deploying Digixbot to the blockchain...     ".black.on_green.blink
    puts "\n"
    build
    @digixbot_configuration.as(@owner)
    @digixbot_users.as(@owner)
    @digixbot_ethereum.as(@owner)
    @digixbot.as(@owner)
    @digixbot_configuration.deploy_and_wait(120)
    configuration_address = @digixbot_configuration.address
    @digixbot_users.deploy_and_wait(120, configuration_address)
    @digixbot_ethereum.deploy_and_wait(120, configuration_address)
    @digixbot.deploy_and_wait(120, configuration_address)
    @digixbot_configuration.transact_and_wait_set_users_contract(@digixbot_users.address)
    @digixbot_configuration.transact_and_wait_set_bot_contract(@digixbot.address)
    @digixbot_configuration.transact_and_wait_add_coin("eth", @digixbot_ethereum.address) 
    # Write out the deployment yml here to be used by the oracle 
    @configuration = {owner: @owner, digixbot_configuration: @digixbot_configuration.address, digixbot_users: @digixbot_users.address, digixbot_ethereum: @digixbot_ethereum.address, digixbot: @digixbot.address}
    File.open("deployment.yml", 'w') {|f| f.puts @configuration.to_yaml }
    puts "Deployment Summary"
    puts "------------------\n"
    puts "DigixbotConfiguration: ".colorize(:green) + "#{@digixbot_configuration.address}".colorize(:white)
    puts "DigixbotUsers:         ".colorize(:magenta) + "#{@digixbot_users.address}".colorize(:white)
    puts "DigixbotEthereum:      ".colorize(:blue) + "#{@digixbot_ethereum.address}".colorize(:white)
    puts "Digixbot:              ".colorize(:yellow) + "#{@digixbot.address}".colorize(:white)
    puts "\nDeployed as #{@owner}".colorize(:cyan)
    puts "\nDeployment file saved as deployment.yml"
  end

end
