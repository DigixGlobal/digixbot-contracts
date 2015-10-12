contract DigixbotEthereum {

  address config;

  mapping(uint => uint) balances;

  function DigixbotEthereum(address _config) {
    config = _config;
  }

  function getUsersContract() public returns (address) {
    address(config).call("d0f46c0b");
  }

  function getBotContract() public returns (address) {
    address(config).call("0f8b70c9");
  }

  modifier ifbot { if (msg.sender == getBotContract()) _ }
  modifier ifusers { if (msg.sender == getUsersContract()) _ }

  function deposit(bytes32 _uid, uint _amt) ifbot {
    balances[_uid] += _amt;
  }

  /// @notice Send coins to a user's account
  /// @param _sender Sender's User ID
  /// @param _recipient Recipient's User ID
  /// @param _amt Amount to send
  function send(bytes32 _sender, bytes32 _recipient, uint _amt) ifusers {
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

  /// @notice Get users's non-multisignature account balance
  /// @param _uid User ID of user
  function getBalance(bytes32 _uid) public returns (uint) {
    return balances[_uid];
  }

  function totalBalance() public returns (uint) {
    return this.balance;
  }



}
