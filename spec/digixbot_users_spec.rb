RSpec.describe "DigixbotUsers" do

  before(:all) do
    @project = Project.new
    @project.build
    @client = @project.client
    @owner = @project.owner
    @accounts = @project.accounts
    @digixbot_configuration = @project.digixbot_configuration
    @digixbot_users = @project.digixbot_users
    @user1, @user2, @user3, @user4, @user5, @user6 = @accounts
    @digixbot_configuration.as(@owner)
    @digixbot_users.as(@owner)
    @digixbot_configuration.deploy_and_wait(120)
    @configuration_address = @digixbot_configuration.deployment.contract_address
    @digixbot_users.deploy_and_wait(120, @configuration_address)
    @digixbot_configuration.transact_and_wait_set_users_contract(@digixbot_users.deployment.contract_address)
  end

  describe "Contract Construction and Deployment" do

    context "Binary" do

      it "should be valid" do
        expect(@digixbot_users.deployment.valid_deployment).to be(true)
      end

    end

    context "getConfig()" do

      it "should return the address for DigixbotConfiguration" do
        expect(@digixbot_users.call_get_config[:formatted][0]).to eq(@configuration_address)
      end

    end

    context "getBotContract()" do

      it "should return the address for Digixbot" do
        expect(@digixbot_users.call_get_owner[:formatted][0]).to eq(@owner)
      end

    end

  end

  describe "Contract Functions" do

    context "getBotContract()" do

      it "should get the bot contract address from configuration" do
        @digixbot_configuration.as(@owner)
        @digixbot_configuration.transact_and_wait_set_bot_contract(@user1)
        expect(@digixbot_users.call_get_bot_contract[:formatted][0]).to eq(@user1)
      end

    end

    context "addUser(), setUserAccount(), getUserId(), and getUserAccount()" do

      it "should add a new user" do
        @digixbot_users.as(@user1)
        @digixbot_users.transact_and_wait_add_user("eufemio")
        @digixbot_users.transact_and_wait_set_user_account("eufemio", @user2)
        expect(@digixbot_users.call_get_user_id(@user2)[:formatted][0]).to eq("eufemio")
        expect(@digixbot_users.call_get_user_account("eufemio")[:formatted][0]).to eq(@user2)
      end

      it "should not allow anyone but the bot account to change user information" do
        @digixbot_users.as(@user2)
        @digixbot_users.transact_and_wait_set_user_account("eufemio", @user3)
        expect(@digixbot_users.call_get_user_id(@user2)[:formatted][0]).to eq("eufemio")
        expect(@digixbot_users.call_get_user_account("eufemio")[:formatted][0]).to eq(@user2)
      end
      
    end

  end

end
