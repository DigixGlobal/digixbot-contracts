RSpec.describe "DigixbotEthereum" do

  before :all do
    @project = Project.new
    @project.build
    @client = @project.client
    @owner = @project.owner
    @accounts = @project.accounts
    @digixbot_configuration = @project.digixbot_configuration
    @digixbot_users = @project.digixbot_users
    @digixbot_ethereum = @project.digixbot_ethereum
    @user1, @user2, @user3, @user4, @user5, @user6 = @accounts
    @digixbot_configuration.as(@owner)
    @digixbot_users.as(@owner)
    @digixbot_ethereum.as(@owner)
    @digixbot_configuration.deploy_and_wait(120)
    @configuration_address = @digixbot_configuration.address
    @digixbot_users.deploy_and_wait(120, @configuration_address)
    @digixbot_ethereum.deploy_and_wait(120, @configuration_address)
    @digixbot_configuration.transact_and_wait_set_users_contract(@digixbot_users.address)
    @digixbot_configuration.transact_and_wait_set_bot_contract(@owner)
  end

  describe "Contract Construction and Deployment" do

    context "Binary" do

      it "should be valid" do
        expect(@digixbot_ethereum.deployment.valid_deployment).to be(true)
      end

    end

    context "getConfig()" do

      it "should return the address for DigixbotConfiguration" do
        expect(@digixbot_ethereum.call_get_config[:formatted][0]).to eq(@digixbot_configuration.address)
      end

    end

    context "getUsersContract()" do

      it "should return the address for DigixbotUsers" do
        expect(@digixbot_ethereum.call_get_users_contract[:formatted][0]).to eq(@digixbot_users.address)
      end

    end

    context "getBotContract()" do

      it "should return the address for Digixbot" do
        expect(@digixbot_users.call_get_bot_contract[:formatted][0]).to eq(@owner)
      end

    end

    context "getUserId() and getUserAcount()" do

      it "should return a user ID from an address or address from a user ID" do
        user_id = SecureRandom.hex(4)
        @digixbot_users.as(@owner)
        @digixbot_users.transact_and_wait_add_user(user_id)
        @digixbot_users.transact_and_wait_set_user_account(user_id, @user1)
        expect(@digixbot_ethereum.call_get_user_id(@user1)[:formatted][0]).to eq(user_id)
        expect(@digixbot_ethereum.call_get_user_account(user_id)[:formatted][0]).to eq(@user1)
      end

    end

    context "depositCoin() and getBalance()" do

      it "should deposit a given amount of coins to user" do
        user_id = SecureRandom.hex(4)
        amount = SecureRandom.random_number(1000000000)
        @digixbot_users.as(@owner)
        @digixbot_users.transact_and_wait_add_user(user_id)
        @digixbot_users.transact_and_wait_set_user_account(user_id, @user1)
        @digixbot_configuration.transact_and_wait_add_coin("eth", @digixbot_ethereum.address)
        @digixbot_ethereum.transact_and_wait_deposit_coin(user_id, amount) 
        expect(@digixbot_ethereum.call_get_balance(user_id)[:formatted][0]).to eq(amount)

      end

    end
    
    context "sendCoin()" do

      it "should send a given amount of coins from sender to recipient" do
        @digixbot_users.as(@owner)
        sender_id = SecureRandom.hex(4)
        recipient_id = SecureRandom.hex(4)
        sender_balance = SecureRandom.random_number(1000000000)
        recipient_balance = SecureRandom.random_number(1000000000)
        sending_amount = SecureRandom.random_number(300)
        @digixbot_ethereum.transact_and_wait_deposit_coin(sender_id, sender_balance)
        @digixbot_ethereum.transact_and_wait_deposit_coin(recipient_id, recipient_balance)
        expect(@digixbot_ethereum.call_get_balance(sender_id)[:formatted][0]).to eq(sender_balance)
        expect(@digixbot_ethereum.call_get_balance(recipient_id)[:formatted][0]).to eq(recipient_balance)
        @digixbot_ethereum.transact_and_wait_send_coin(sender_id, recipient_id, sending_amount)
        sender_expected_balance = sender_balance - sending_amount
        recipient_expected_balance = recipient_balance + sending_amount
        expect(@digixbot_ethereum.call_get_balance(sender_id)[:formatted][0]).to eq(sender_expected_balance)
        expect(@digixbot_ethereum.call_get_balance(recipient_id)[:formatted][0]).to eq(recipient_expected_balance)
      end

    end

    context "withdrawCoin()" do

      it "should withdraw a given amount of coin from user" do
        pending "WIP"
        expect(false).to be(true)
      end
      
    end

    context "totalBalance()" do

      it "should return the total coin balance held in the wallet" do
        pending "WIP"
        expect(false).to be(true)
      end

    end

    context "withdrawCoinExternal()" do

      it "should withdraw a given amount of coin to the user's address" do
        pending "WIP"
        expoect(false).to be(true)
      end

    end
    
  end

end




