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
    @digixbot_configuration.transact_and_wait_add_coin("eth", @digixbot_ethereum.address)
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

  end

  describe "Contract Functions" do 
    context "Deposits, Withdrawals, Balances, and Sending" do

      before(:context) do
        @digixbot_users.as(@owner)
        @digixbot_users.transact_and_wait_add_user("user1")
        @digixbot_users.transact_and_wait_set_user_account("user1", @user1)
        @digixbot_users.transact_and_wait_add_user("user2")
        @digixbot_users.transact_and_wait_set_user_account("user2", @user2)
        @digixbot_users.transact_and_wait_add_user("user3")
        @digixbot_users.transact_and_wait_set_user_account("user2", @user2)
      end

      context "depositCoin() and getBalance()" do

        it "should deposit a given amount of coins to user" do
          user_id = SecureRandom.hex(4)
          amount = 50000000000000000000
          @digixbot_users.as(@owner)
          @digixbot_users.transact_and_wait_add_user(user_id)
          @digixbot_users.transact_and_wait_set_user_account(user_id, @user1)
          @digixbot_ethereum.transact_and_wait_deposit_coin(user_id, amount) 
          expect(@digixbot_ethereum.call_get_balance(user_id)[:formatted][0]).to eq(amount)
        end

      end
    
      context "sendCoin()" do

        it "should send a given amount of coins from sender to recipient" do
          @digixbot_users.as(@owner)
          sender_id = SecureRandom.hex(4)
          recipient_id = SecureRandom.hex(4)
          sender_balance = 22000000000000000000
          recipient_balance = 33000000000000000000
          sending_amount = 800000000000000000          
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

      context "function() (External deposit transactions to DigixbotEthereum)" do

        it "should deposit the received amount to user" do
          gas = 200000
          gas_price = 60000000000
          sending_amount = 10000000000000000000
          sending_amount_hex = "0x" + sending_amount.to_s(16)
          user2_balance_1 = @digixbot_ethereum.call_get_balance("user2")[:formatted][0]
          txid = @digixbot_users.connection.send_transaction({from: @user2, to: @digixbot_ethereum.address, gas: gas, gasPrice: gas_price, value: sending_amount_hex})["result"]
          transaction = Ethereum::Transaction.new(txid, @digixbot_ethereum.connection, {})
          transaction.wait_for_miner(1500)
          user2_balance_2 = @digixbot_ethereum.call_get_balance("user2")[:formatted][0]
          expect(user2_balance_2 - user2_balance_1).to eq(sending_amount)
        end

      end

      context "withdrawCoinExt() and getBalance()" do

        it "should withdraw amount from transaction sender's account into their external wallet" do
          @digixbot_ethereum.as(@user2)
          user2_balance_1 = @digixbot_ethereum.call_get_balance('user2')[:formatted][0]
          user2_account_balance_1 = @digixbot_users.connection.get_balance(@user2)["result"].hex
          user2_withdrawal_amount = 3000000000000000000
          tx = @digixbot_ethereum.transact_and_wait_withdraw_coin_ext(user2_withdrawal_amount)
          tx_gas_used = @digixbot_ethereum.connection.get_transaction_by_hash(tx.id)["result"]["gas"].hex
          tx_gas_price = @digixbot_ethereum.connection.get_transaction_by_hash(tx.id)["result"]["gasPrice"].hex
          tx_fees = tx_gas_used * tx_gas_price
          user2_balance_2 = @digixbot_ethereum.call_get_balance('user2')[:formatted][0]
          user2_account_balance_2 = @digixbot_users.connection.get_balance(@user2)["result"].hex
          expect(user2_balance_1 - user2_balance_2).to eq(user2_withdrawal_amount)
          expect(user2_account_balance_2 - user2_account_balance_1).to be_within(tx_fees).of(user2_withdrawal_amount)
        end

      end

      context "withdrawCoin()" do

        it "should withdraw amount from user's account into their external wallet" do
          @digixbot_ethereum.as(@owner)
          user2_balance_1 = @digixbot_ethereum.call_get_balance('user2')[:formatted][0]
          user2_account_balance_1 = @digixbot_users.connection.get_balance(@user2)["result"].hex
          user2_withdrawal_amount = 3000000000000000000
          tx = @digixbot_ethereum.transact_and_wait_withdraw_coin('user2', user2_withdrawal_amount)
          tx_gas_used = @digixbot_ethereum.connection.get_transaction_by_hash(tx.id)["result"]["gas"].hex
          tx_gas_price = @digixbot_ethereum.connection.get_transaction_by_hash(tx.id)["result"]["gasPrice"].hex
          tx_fees = tx_gas_used * tx_gas_price
          user2_balance_2 = @digixbot_ethereum.call_get_balance('user2')[:formatted][0]
          user2_account_balance_2 = @digixbot_users.connection.get_balance(@user2)["result"].hex
          expect(user2_balance_1 - user2_balance_2).to eq(user2_withdrawal_amount)
          expect(user2_account_balance_2 - user2_account_balance_1).to be_within(tx_fees).of(user2_withdrawal_amount)
        end

      end
      
      context "totalBalance()" do

        it "should show the total ETH balance for contract account" do
          function_result = @digixbot_ethereum.call_total_balance[:formatted][0]
          get_balance_result = @digixbot_ethereum.connection.get_balance(@digixbot_ethereum.address)["result"].hex
          expect(function_result).to eq(get_balance_result)
        end

      end

    end
      
  end

end





