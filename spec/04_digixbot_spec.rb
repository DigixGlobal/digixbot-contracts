RSpec.describe "Digixbot" do

  before :all do
    @project = Project.new
    @project.build
    @client = @project.client
    @owner = @project.owner
    @accounts = @project.accounts
    @digixbot_configuration = @project.digixbot_configuration
    @digixbot_users = @project.digixbot_users
    @digixbot_ethereum = @project.digixbot_ethereum
    @digixbot = @project.digixbot
    @user1, @user2, @user3, @user4, @user5, @user6 = @accounts
    @digixbot_configuration.as(@owner)
    @digixbot_users.as(@owner)
    @digixbot_ethereum.as(@owner)
    @digixbot.as(@owner)
    @digixbot_configuration.deploy_and_wait(120)
    @configuration_address = @digixbot_configuration.address
    @digixbot_users.deploy_and_wait(120, @configuration_address)
    @digixbot_ethereum.deploy_and_wait(120, @configuration_address)
    @digixbot.deploy_and_wait(120, @configuration_address)
    @digixbot_configuration.transact_and_wait_set_users_contract(@digixbot_users.address)
    @digixbot_configuration.transact_and_wait_set_bot_contract(@digixbot.address)
    @digixbot_configuration.transact_and_wait_add_coin("eth", @digixbot_ethereum.address)
  end

  describe "Contract Construction and Deployment" do

    context "Binary" do

      it "should be valid" do
        expect(@digixbot.deployment.valid_deployment).to be(true)
      end

    end

    context "getConfig()" do

      it "should return the address for DigixbotConfiguration" do
        expect(@digixbot.call_get_config[:formatted][0]).to eq(@digixbot_configuration.address)
      end

    end

    context "getUsersContract()" do

      it "should return the address for DigixbotUsers" do
        expect(@digixbot.call_get_users_contract[:formatted][0]).to eq(@digixbot_users.address)
      end

    end

    context "getBotContract()" do

      it "should return the address for Digixbot" do
        expect(@digixbot_users.call_get_bot_contract[:formatted][0]).to eq(@digixbot.address)
      end

    end

    context "getCoinWallet()" do

      it "should return the address for DigixbotEthereum" do
        expect(@digixbot.call_get_coin_wallet("eth")[:formatted][0]).to eq(@digixbot_ethereum.address)
      end

    end

  end

  describe "Contract Functions" do

    before(:context) do
      @digixbot.as(@owner)
      @digixbot.transact_and_wait_add_user("user1")
      @digixbot.transact_and_wait_set_user_account("user1", @user1)
      @digixbot.transact_and_wait_add_user("user2")
      @digixbot.transact_and_wait_set_user_account("user2", @user2)
      @digixbot.transact_and_wait_add_user("user3")
      @digixbot.transact_and_wait_set_user_account("user2", @user2)
      gas = 200000
      gas_price = 60000000000
      sending_amount = 1000000000000000000000
      sending_amount_hex = "0x" + sending_amount.to_s(16)
      txid = @digixbot_users.connection.send_transaction({from: @user1, to: @digixbot_ethereum.address, gas: gas, gasPrice: gas_price, value: sending_amount_hex})["result"]
      transaction = Ethereum::Transaction.new(txid, @digixbot_ethereum.connection, {})
      transaction.wait_for_miner(1500)
    end

    context "addUser(), setUserAccount(), sendCoin() and getCoinBalance()" do

      it "should send given amount of a given coin from given sender to given recipient" do
        @digixbot.as(@owner)
        sender = "user1"
        sender_balance_1 = @digixbot.call_get_coin_balance("eth", sender)[:formatted][0]
        sending_amount = 16000000000000000000
        recipient = SecureRandom.hex(8)
        @digixbot_users.transact_and_wait_add_user(recipient)
        recipient_balance_1 = @digixbot.call_get_coin_balance("eth", recipient)[:formatted][0]
        @digixbot.transact_and_wait_send_coin("eth", sender, recipient, sending_amount)
        sender_balance_2 = @digixbot.call_get_coin_balance("eth", sender)[:formatted][0]
        recipient_balance_2 = @digixbot.call_get_coin_balance("eth", recipient)[:formatted][0]
        sender_sent = sender_balance_1 - sender_balance_2
        recipient_received = recipient_balance_2 - recipient_balance_1
        expect(sender_sent).to eq(recipient_received)
      end

    end

    context "userCheck()" do

      it "should return true if user exists" do
        user_that_should_exist = SecureRandom.hex(4)
        @digixbot.transact_and_wait_add_user(user_that_should_exist)
        expect(@digixbot.call_user_check(user_that_should_exist)[:formatted][0]).to be(true)
      end

      it "should return false if user does not exist" do
        user_that_should_not_exist = SecureRandom.hex(4)
        expect(@digixbot.call_user_check(user_that_should_not_exist)[:formatted][0]).to be(false)
      end
        
    end

    context "withdrawCoin()" do

      it "should withdraw given amount for a given coin to user" do
        @digixbot.as(@owner)
        withdrawer = "user1"
        withdrawer_balance_1 = @digixbot.call_get_coin_balance("eth", withdrawer)[:formatted][0]
        withdrawer_wallet_balance_1 = @digixbot.connection.get_balance(@user1)["result"].hex
        withdrawal_amount = 3000000000000000000
        @digixbot.transact_and_wait_withdraw_coin("eth", withdrawer, withdrawal_amount)
        withdrawer_balance_2 = @digixbot.call_get_coin_balance("eth", withdrawer)[:formatted][0]
        withdrawer_wallet_balance_2 = @digixbot.connection.get_balance(@user1)["result"].hex
        expect(withdrawer_wallet_balance_2 - withdrawer_wallet_balance_1).to eq(withdrawal_amount)
        expect(withdrawer_balance_1 - withdrawer_balance_2).to eq(withdrawal_amount)
      end

    end

    context "getTotalBalance()" do

      it "should return the total balance for a given coin" do
        expect(@digixbot.call_get_total_balance("eth")[:formatted][0]).to be > 0
      end

    end

  end

end




