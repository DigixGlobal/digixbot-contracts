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

  function getBotContract() public returns (address) {
    address(config).call("0f8b70c9");
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

