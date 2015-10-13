RSpec.describe "DigixbotConfiguration" do

  before(:all) do
    @project = Project.new
    @project.build
    @client = @project.client
    @owner = @project.owner
    @accounts = @project.accounts
    @digixbot_configuration = @project.digixbot_configuration
    @user1, @user2, @user3, @user4, @user5, @user6 = @accounts
    @digixbot_configuration.as(@owner)
    @digixbot_configuration.deploy_and_wait(120)
  end

  describe "Contract Construction and Deployment" do

    context "binary" do

      it "should be valid" do
        expect(@digixbot_configuration.deployment.valid_deployment).to be(true)
      end

    end

    context "getOwner()" do

      it "should return the address for @owner" do
        expect(@digixbot_configuration.call_get_owner[:formatted][0]).to eq(@owner)
      end

    end

  end

  describe "Contract Functions" do

    context "setBotContract() and getBotContract()" do

      it "should set the botcontract variable to @bot" do
        @digixbot_configuration.transact_and_wait_set_bot_contract(@owner)
        expect(@digixbot_configuration.call_get_bot_contract[:formatted][0]).to eq(@owner)
      end

      it "should only allow owner to call it" do
        @digixbot_configuration.as(@user1)
        @digixbot_configuration.transact_and_wait_set_bot_contract(@user1)
        expect(@digixbot_configuration.call_get_bot_contract[:formatted][0]).to eq(@owner)
      end

    end

    context "setUsersContract() and getUsersContract()" do

      it "should set the userscontract to @user2" do
        @digixbot_configuration.as(@owner)
        @digixbot_configuration.transact_and_wait_set_users_contract(@user2)
        expect(@digixbot_configuration.call_get_users_contract[:formatted][0]).to eq(@user2)
      end

      it "should only allow owner to call it" do
        @digixbot_configuration.as(@user1)
        @digixbot_configuration.transact_and_wait_set_bot_contract(@user1)
        expect(@digixbot_configuration.call_get_users_contract[:formatted][0]).to eq(@user2)
      end

    end

    context "lockConfiguration()" do

      it "should lock the configuration" do
        @digixbot_configuration.as(@owner)
        transaction = @digixbot_configuration.transact_and_wait_lock_configuration
        expect(transaction.class).to be(Ethereum::Transaction)
      end

      context "setBotContract()" do

        it "should check if configuration is locked" do
          @digixbot_configuration.as(@owner)
          @digixbot_configuration.transact_and_wait_set_bot_contract(@user1)
          expect(@digixbot_configuration.call_get_bot_contract[:formatted][0]).not_to eq(@user1)
        end

      end

      context "setUsersContract()" do

        it "should check if configuration is locked" do
          @digixbot_configuration.as(@owner)
          @digixbot_configuration.transact_and_wait_set_users_contract(@user3)
          expect(@digixbot_configuration.call_get_users_contract[:formatted][0]).not_to eq(@user3)
        end

      end

    end

    context "addCurrency() and getCurrencyWallet()" do

      it "should add a new currency" do
        @digixbot_configuration.as(@owner)
        @digixbot_configuration.transact_and_wait_add_currency("eth", @user3)
        expect(@digixbot_configuration.call_get_currency_wallet("eth")[:formatted][0]).to eq(@user3)
      end

      it "should not add an existing currency" do
        @digixbot_configuration.as(@owner)
        @digixbot_configuration.transact_and_wait_add_currency("eth", @user1)
        expect(@digixbot_configuration.call_get_currency_wallet("eth")[:formatted][0]).not_to eq(@user1)
        @digixbot_configuration.transact_and_wait_add_currency("dgx", @user3)
        expect(@digixbot_configuration.call_get_currency_wallet("dgx")[:formatted][0]).to eq(@user3)
      end

    end

  end

end
