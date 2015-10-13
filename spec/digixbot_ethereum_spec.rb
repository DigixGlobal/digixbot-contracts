RSpec.describe "DigixbotEthereum" do

  before(:all) do
    @client = Ethereum::HttpClient.new("172.16.135.110", "8545")
    @contract_init1 = Ethereum::Initializer.new("#{ENV["PWD"]}/contracts/DigixbotConfiguration.sol", @client)
    @contract_init1.build_all
    @digixbotconfiguration = DigixbotConfiguration.new
    @contract_init2 = Ethereum::Initializer.new("#{ENV["PWD"]}/contracts/DigixbotUsers.sol", @client)
    @contract_init2.build_all
    @digixbotusers = DigixbotUsers.new
    @accounts = @digixbotusers.connection.accounts["result"]
    @coinbase = @digixbotusers.connection.coinbase["result"]
    @user1 = @accounts[1]
    @user2 = @accounts[2]
    @user3 = @accounts[3]
    @digixbotconfiguration.as(@coinbase)
    @digixbotusers.as(@coinbase)
    @digixbotconfiguration.deploy_and_wait(120)
    @digixbotusers.deploy_and_wait(120, @digixbotconfiguration.deployment.contract_address)
    @formatter = Ethereum::Formatter.new
  end

  describe "Contract Construction and Deployment" do

    it "Should produce a correct binary after deployment" do
      expect(@digixbotusers.deployment.valid_deployment).to be(true)
    end

    describe "getConfig()" do

      it "Should have the configuration address set during deployment" do
        expect(@digixbotusers.call_get_config[:formatted][0]).to eq(@digixbotconfiguration.deployment.contract_address)
      end

    end

    describe "getBotContract()" do

      it "Should set the deployer as the owner at deployment" do
        expect(@digixbotusers.call_get_owner[:formatted][0]).to eq(@coinbase)
      end

    end

  end

  describe "Contract Functions" do

    describe "getBotContract()" do

      it "should get the bot contract address from configuration" do
        @digixbotconfiguration.as(@coinbase)
        @digixbotconfiguration.transact_and_wait_set_bot_contract(@user1)
        expect(@digixbotusers.call_get_bot_contract[:formatted][0]).to eq(@user1)
      end

    end

    describe "addUser(), setUserAccount(), getUserId(), and getUserAccount()" do

      it "should add a new user" do
        @digixbotusers.as(@user1)
        @digixbotusers.transact_and_wait_add_user("eufemio")
        @digixbotusers.transact_and_wait_set_user_account("eufemio", @user2)
        expect(@digixbotusers.call_get_user_id(@user2)[:formatted][0]).to eq("eufemio")
        expect(@digixbotusers.call_get_user_account("eufemio")[:formatted][0]).to eq(@user2)
      end

      it "should not allow anyone but the bot account to change user information" do
        @digixbotusers.as(@user2)
        @digixbotusers.transact_and_wait_set_user_account("eufemio", @user3)
        expect(@digixbotusers.call_get_user_id(@user2)[:formatted][0]).to eq("eufemio")
        expect(@digixbotusers.call_get_user_account("eufemio")[:formatted][0]).to eq(@user2)
      end
      
    end

  end

end
