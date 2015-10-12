#require 'ethereum'
#require 'securerandom'
#client = Ethereum::HttpClient.new("172.16.135.110", "8545")
#contract_init = Ethereum::Initializer.new("#{ENV['PWD']}/contracts/DigixbotConfiguration.sol", client)
#contract_init.build_all

#RSpec.describe DigixbotConfiguration do

  #before(:context) do
    #@etw = DigixbotConfiguration.new
    #@etw.deploy_and_wait
    #@coinbase = @etw.connection.coinbase["result"]
    #@accounts = @etw.connection.accounts["result"]
    #@bot = (@accounts - [@coinbase]).sample
    #@user1 = (@accounts - [@coinbase, @bot]).sample
    #@accounts.delete(@coinbase)
    #@formatter = Ethereum::Formatter.new
  #end

  #describe "Contract Code" do
    #it "Should produce a correct binary after deployment" do
      #expect(@etw.deployment.valid_deployment).to be(true)
    #end
  #end

  #describe "Contract Functions" do
    #it "getBot() should return the deployment account address" do
      #formatted_result = @formatter.to_address(@etw.call_get_bot[:raw])
      #expect(formatted_result).to eq(@coinbase)
    #end

    #it "setBot(bot_address) should set bot contract storage variable to bot_address" do
      #@etw.transact_and_wait_set_bot(@bot)
      #@etw.as(@bot)
      #formatted_result = @formatter.to_address(@etw.call_get_bot[:raw])
      #expect(formatted_result).to eq(@bot)
    #end
  
    #it "deposit(user_id, amount) should deposit amount to user_id" do
      #@etw.as(@bot)
      #amount = 31337
      #user = SecureRandom.hex(8)
      #@etw.transact_and_wait_deposit(user, amount)
      #formatted_result = @formatter.to_int(@etw.call_get_balance(user)[:raw])
      #expect(formatted_result).to eq(amount)
    #end

    #it "sendAsBot(sender, recipient, amount) should deduct amount from sender and credit amount to recipient" do
      #@etw.as(@bot)
      #sender = SecureRandom.hex(8)
      #recipient = SecureRandom.hex(8)
      #sender_balance = 2996
      #recipient_balance = 2113
      #sending_amount = 300
      #@etw.transact_and_wait_deposit(sender, sender_balance)
      #@etw.transact_and_wait_deposit(recipient, recipient_balance)
      #recipient_balance_before = @formatter.to_int(@etw.call_get_balance(recipient)[:raw])
      #sender_balance_before = @formatter.to_int(@etw.call_get_balance(sender)[:raw])
      #expect(sender_balance).to eq(sender_balance_before)
      #expect(recipient_balance).to eq(recipient_balance_before)
      #@etw.transact_and_wait_send_as_bot(sender, recipient, sending_amount)
      #recipient_balance_after = @formatter.to_int(@etw.call_get_balance(recipient)[:raw])
      #sender_balance_after = @formatter.to_int(@etw.call_get_balance(sender)[:raw])
      #expect(sender_balance_after).to eq(sender_balance_before - sending_amount)
      #expect(recipient_balance_after).to eq(recipient_balance_before + sending_amount)
    #end

  #end

  #describe "Contract Access Control and Security" do

    #it "setBot(bot_address) shold only be allowed for owner" do
      #@etw.as(@user1)
      #@etw.transact_and_wait_set_bot(@user1)
      #formatted_result = @formatter.to_address(@etw.call_get_bot[:raw])
      #expect(formatted_result).not_to eq(@user1)
    #end

    #it "deposit(user_id, amount) should only be allowed from bot" do
      #@etw.as(@user1)
      #amount = 25957
      #user1 = SecureRandom.hex(8)
      #@etw.transact_and_wait_deposit(user1, amount)
      #formatted_result = @formatter.to_int(@etw.call_get_balance(user1)[:raw])
      #expect(formatted_result).to eq(0)
    #end

    #it "getBalance(user_id) should show 0 for non-existent user IDs" do
      #@etw.as(@coinbase)
      #nonexistent1 = @formatter.to_int(@etw.call_get_balance("nonexistent1")[:raw])
      #nonexistent2 = @formatter.to_int(@etw.call_get_balance("nonexistent2")[:raw])
      #nonexistent3 = @formatter.to_int(@etw.call_get_balance("nonexistent3")[:raw])
      #expect([nonexistent1, nonexistent2, nonexistent3]).to contain_exactly(0, 0, 0) 
    #end

    #it "sendAsBot(sender, recipient, amount) should only be allowed from bot" do
      #@etw.as(@bot)
      #user1 = SecureRandom.hex(8)
      #user2 = SecureRandom.hex(8)
      #user1_starting_balance = 3000
      #user2_starting_balance = 4000
      #@etw.transact_and_wait_deposit(user1, user1_starting_balance)
      #@etw.transact_and_wait_deposit(user2, user2_starting_balance)
      #expect(@formatter.to_int(@etw.call_get_balance(user1)[:raw])).to eq(user1_starting_balance)
      #expect(@formatter.to_int(@etw.call_get_balance(user2)[:raw])).to eq(user2_starting_balance)
      #@etw.as(@user1)
      #@etw.transact_and_wait_deposit(user1, 250)
      #expect(@formatter.to_int(@etw.call_get_balance(user1)[:raw])).to eq(user1_starting_balance)
    #end

  #end


#end
