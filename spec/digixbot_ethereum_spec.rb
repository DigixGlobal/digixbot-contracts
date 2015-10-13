RSpec.describe "DigixbotEthereum" do

  before(:all) do
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
  end

  describe "Contract Construction and Deployment" do

    context "binary deployment" do

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
        pending "Digixbot does not exist yet"
        expect(false).to be(true)
      end
    end
    
  end

end




