contract DigixbotConfiguration {
  function DigixbotConfiguration();
  function lockConfiguration();
  function getBotContract() returns(address );
  function getCoinWallet(bytes4 _coin) constant returns(address );
  function addCoin(bytes4 _name,address _wallet);
  function getOwner() constant returns(address );
  function setUsersContract(address _userscontract);
  function getUsersContract() returns(address );
  function setBotContract(address _botcontract);
}

contract DigixbotUsers {

  struct User {
    bytes32 id; 
    address account;
  }

  address owner;
  address config;

  mapping(bytes32 => User) users;
  mapping(address => bytes32) ids;

  event EventLog(uint indexed _eventType, bytes32 indexed _eventData);
  enum EventTypes { AddUser, SetAccount }

  function DigixbotUsers(address _config) {
    owner = msg.sender;
    config = _config;
  }

  function getOwner() public returns (address) {
    return owner;
  }

  function getConfig() public returns (address) {
    return config;
  }

  function getBotContract() public returns (address) {
    return DigixbotConfiguration(config).getBotContract();
  }

  modifier ifowner { if (msg.sender == owner) _ }
  modifier ifbot { if (msg.sender == getBotContract()) _ }

  function addUser(bytes32 _id) ifbot {
    users[_id].id = _id;
    EventLog(uint(EventTypes.AddUser), _id);
  }

  function setUserAccount(bytes32 _id, address _account) ifbot {
    users[_id].account = _account;
    ids[_account] = _id; 
    EventLog(uint(EventTypes.SetAccount), _id);
  }

  function getUserId(address _account) public returns (bytes32) {
    return ids[_account];
  }

  function getUserAccount(bytes32 _id) public returns (address) {
    User _user = users[_id];
    return _user.account;
  }

}

