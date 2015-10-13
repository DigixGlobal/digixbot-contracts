contract DigixbotConfiguration {
  function DigixbotConfiguration();
  function lockConfiguration();
  function getBotContract() returns(address );
  function getCurrencyWallet(bytes4 _currency) constant returns(address _ca);
  function getOwner()constant returns(address );
  function setUsersContract(address _userscontract);
  function getUsersContract()returns(address _uca);
  function setBotContract(address _botcontract);
  function addCurrency(bytes4 _name,address _wallet);
}

contract DigixbotUsers {
  function DigixbotUsers(address _config);
  function getBotContract() returns(address );
  function setUserAccount(bytes32 _id,address _account);
  function getUserId(address _account) returns(bytes32 );
  function getUserAccount(bytes32 _id)returns(address );
  function getOwner()returns(address );
  function addUser(bytes32 _id);
  function getConfig()returns(address );
}

contract DigixbotEthereum {

  address config;

  mapping(bytes32 => uint) balances;

  function DigixbotEthereum(address _config) {
    config = _config;
  }

  function() {
    bytes32 _userid = getUserId(msg.sender);
    balances[_userid] += msg.value;
  }

  function getConfig() public returns (address) {
    return config;
  }

  function getUsersContract() public returns (address) {
    return DigixbotConfiguration(config).getUsersContract();
  }

  function getBotContract() public returns (address) {
    return DigixbotConfiguration(config).getBotContract();
  }

  function getUserId(address _address) public returns (bytes32) {
    return DigixbotUsers(getUsersContract()).getUserId(_address);
  }

  modifier ifbot { if (msg.sender == getBotContract()) _ }
  modifier ifusers { if (msg.sender == getUsersContract()) _ }

  function deposit(bytes32 _uid, uint _amt) ifbot {
    balances[_uid] += _amt;
  }

  function send(bytes32 _sender, bytes32 _recipient, uint _amt) ifbot {
    if (balances[_sender] > _amt) {
      balances[_sender] -= _amt;
      balances[_recipient] += _amt;
    }
  }

  function withdraw(bytes32 _user, uint _amount) ifbot {
    if (balances[_user] >= _amount) {
      balances[_user] -= _amount;
      this.send(_amount);
    }
  }

  function getBalance(bytes32 _uid) public returns (uint) {
    return balances[_uid];
  }

  function totalBalance() public returns (uint) {
    return this.balance;
  }

}
