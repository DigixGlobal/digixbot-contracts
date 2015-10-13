require 'ethereum'
require 'active_support'
require 'active_support/core_ext'
require 'pry'

class Project

  CONTRACTS = %w(DigixbotConfiguration DigixbotUsers DigixbotEthereum)
  
  CONTRACTS.each do |contract|
    self.send :attr_accessor, contract.underscore.to_sym
  end

  attr_accessor :client, :owner, :formatter, :accounts 

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

end
