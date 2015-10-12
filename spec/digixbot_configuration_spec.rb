require 'ethereum'
require 'securerandom'
client = Ethereum::HttpClient.new("172.16.135.110", "8545")
contract_init = Ethereum::Initializer.new("#{ENV['PWD']}/contracts/DigixbotConfiguration.sol", client)
contract_init.build_all

RSpec.describe DigixbotConfiguration do

  before(:context) do
    @etw = DigixbotConfiguration.new
    @etw.deploy_and_wait
    @accounts = @etw.connection.accounts["result"]
    @coinbase = @accounts[0]
    @user1 = @accounts[1]
    @user2 = @accounts[2]
    @user3 = @accounts[3]
    @accounts.delete(@coinbase)
    @formatter = Ethereum::Formatter.new
  end

  describe "Contract Code" do
    it "Should produce a correct binary after deployment" do
      expect(@etw.deployment.valid_deployment).to be(true)
    end
  end

  describe "Contract Functions" do

    describe "setBotContract() and getBotContract()" do

      it "should set the botcontract variable to @coinbase" do
        @etw.transact_and_wait_set_bot_contract(@coinbase)
        formatted_result = @formatter.to_address(@etw.call_get_bot_contract[:raw])
        expect(formatted_result).to eq(@coinbase)
      end

      it "should only allow owner to call it" do
        @etw.as(@user1)
        @etw.transact_and_wait_set_bot_contract(@user1)
        formatted_result = @formatter.to_address(@etw.call_get_bot_contract[:raw])
        expect(formatted_result).to eq(@coinbase)
      end

    end

    describe "setUsersContract() and getUsersContract()" do

      it "should set the userscontract to @user2" do
        @etw.as(@coinbase)
        @etw.transact_and_wait_set_users_contract(@user2)
        formatted_result = @formatter.to_address(@etw.call_get_users_contract[:raw])
        expect(formatted_result).to eq(@user2)
      end

      it "should only allow owner to call it" do
        @etw.as(@user1)
        @etw.transact_and_wait_set_bot_contract(@user1)
        formatted_result = @formatter.to_address(@etw.call_get_users_contract[:raw])
        expect(formatted_result).to eq(@user2)
      end

    end

    describe "lockConfiguration()" do

      it "should lock the configuration" do
        @etw.as(@coinbase)
        transaction = @etw.transact_and_wait_lock_configuration
        expect(transaction.class).to be(Ethereum::Transaction)
      end

      describe "setBotContract()" do

        it "should check if configuration is locked" do
          @etw.as(@coinbase)
          @etw.transact_and_wait_set_bot_contract(@user1)
          formatted_result = @formatter.to_address(@etw.call_get_bot_contract[:raw])
          expect(formatted_result).not_to eq(@user1)
        end

      end

      describe "setUsersContract()" do

        it "should check if configuration is locked" do
          @etw.as(@coinbase)
          @etw.transact_and_wait_set_users_contract(@user3)
          formatted_result = @formatter.to_address(@etw.call_get_users_contract[:raw])
          expect(formatted_result).not_to eq(@user3)
        end

      end

    end

  end

end
