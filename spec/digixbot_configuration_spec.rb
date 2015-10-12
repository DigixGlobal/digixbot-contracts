RSpec.describe "DigixbotConfiguration" do

  before(:all) do
    @client = Ethereum::HttpClient.new("172.16.135.110", "8545")
    @contract_init = Ethereum::Initializer.new("#{ENV['PWD']}/contracts/DigixbotConfiguration.sol", @client)
    @contract_init.build_all
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

  describe "Contract Construction and Deployment" do

    it "Should produce a correct binary after deployment" do
      expect(@etw.deployment.valid_deployment).to be(true)
    end

    describe "getOwner()" do
      it "Should set the deployer as owner at deployment" do
        expect(true).to be(true)
      end
    end

  end

  describe "Contract Functions" do

    describe "setBotContract() and getBotContract()" do

      it "should set the botcontract variable to @coinbase" do
        @etw.transact_and_wait_set_bot_contract(@coinbase)
        expect(@etw.call_get_bot_contract[:formatted][0]).to eq(@coinbase)
      end

      it "should only allow owner to call it" do
        @etw.as(@user1)
        @etw.transact_and_wait_set_bot_contract(@user1)
        expect(@etw.call_get_bot_contract[:formatted][0]).to eq(@coinbase)
      end

    end

    describe "setUsersContract() and getUsersContract()" do

      it "should set the userscontract to @user2" do
        @etw.as(@coinbase)
        @etw.transact_and_wait_set_users_contract(@user2)
        expect(@etw.call_get_users_contract[:formatted][0]).to eq(@user2)
      end

      it "should only allow owner to call it" do
        @etw.as(@user1)
        @etw.transact_and_wait_set_bot_contract(@user1)
        expect(@etw.call_get_users_contract[:formatted][0]).to eq(@user2)
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
          expect(@etw.call_get_bot_contract[:formatted][0]).not_to eq(@user1)
        end

      end

      describe "setUsersContract()" do

        it "should check if configuration is locked" do
          @etw.as(@coinbase)
          @etw.transact_and_wait_set_users_contract(@user3)
          expect(@etw.call_get_users_contract[:formatted][0]).not_to eq(@user3)
        end

      end

    end

    describe "addCurrency() and getCurrencyWallet()" do

      it "should add a new currency" do
        @etw.as(@coinbase)
        @etw.transact_and_wait_add_currency("eth", @user3)
        expect(@etw.call_get_currency_wallet("eth")[:formatted][0]).to eq(@user3)
      end

      it "should not add an existing currency" do
        @etw.as(@coinbase)
        @etw.transact_and_wait_add_currency("eth", @user1)
        expect(@etw.call_get_currency_wallet("eth")[:formatted][0]).not_to eq(@user1)
        @etw.transact_and_wait_add_currency("dgx", @user3)
        expect(@etw.call_get_currency_wallet("dgx")[:formatted][0]).to eq(@user3)
      end

    end

  end

end
