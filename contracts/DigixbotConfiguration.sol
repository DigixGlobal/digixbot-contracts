contract DigixbotConfiguration {

  struct CurrencyFunctions {
    bytes4 sendFunction;
    bytes4 withdrawFunction;
  }

  struct Currency {
    bytes4 name;
    address wallet;
    bool locked;
    CurrencyFunctions currencyFunctions;
  }

  address owner;
  address botcontract;
  address userscontract;
  bool locked;

  mapping(bytes4 => Currency) currencies;

  modifier ifowner { if (msg.sender == owner) _ }
  modifier unlesslocked { if (locked == false) _ }

  function DigixbotConfiguration() {
    owner = msg.sender;
    locked = false;
  }

  function setBotContract(address _botcontract) ifowner unlesslocked {
    botcontract = _botcontract;
  }
  
  function getBotContract() public constant returns (address _bca) {
    _bca = botcontract;
  }

  function setUsersContract(address _userscontract) ifowner unlesslocked {
    userscontract = _userscontract;
  }

  function getUsersContract() public constant returns (address _uca) {
    _uca = userscontract;
  }

  function lockConfiguration() ifowner {
    locked = true;
  }

  function addCurrency(bytes4 _name, address _wallet) ifowner {
    Currency _cta = currencies[_name];
    if (_cta.locked == false) {
      _cta.name = _name;
      _cta.wallet = _wallet;
      _cta.locked = true;
    }
  }

  function getCurrencyWallet(bytes4 _currency) public constant returns (address _ca) {
    Currency _ccy = currencies[_currency];
    _ca = _ccy.wallet;
  }

} 

