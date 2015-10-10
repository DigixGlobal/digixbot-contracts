contract EthereumTipWallet {

  struct User {
    uint uid;
    bool multisig;
    address withdrawal;
    address authorized;
  }

  address owner;
  address bot;

  mapping(uint => User) users;

  mapping(bytes32 => uint) balances;

  modifier ifowner { if (msg.sender == owner) _ }
  modifier ifbot { if (msg.sender == bot) _ }

  function EthereumTipWallet() {
    owner = msg.sender;
    bot = msg.sender;
  }

  /// @dev This is for configuring the tipbot contract
  /// @notice Set bot address configuration
  /// @param _ba The bot contract address to use
  function setBot(address _ba) ifowner {
    bot = _ba;
  }

  /// @notice Returns the configured bot address
  function getBot() public constant returns (address _ba) {
    _ba = bot;
  }

  /// @notice Deposit coins to user's non multi-signature account
  /// @param _uid User ID of beneficiary
  /// @param _amt Amount in wei to deposit
  function deposit(bytes32 _uid, uint _amt) ifbot {
    balances[_uid] += _amt;
  }

  function sendAsBot(bytes32 _sender, bytes32 _recipient, uint _amt) ifbot {
    if (balances[_sender] > _amt) {
      balances[_sender] -= _amt;
      balances[_recipient] += _amt;
    }
  }

  /// @notice Get users's non-multisignature account balance
  /// @param _uid User ID of user
  function getBalance(bytes32 _uid) public returns (uint) {
    return balances[_uid];
  }

}
