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

contract Coin {
  function getBotContract() returns(address );
  function getUserId(address _address) returns(bytes32 );
  function withdrawCoin(bytes32 _user,uint256 _amount);
  function depositCoin(bytes32 _uid,uint256 _amt);
  function getBalance(bytes32 _uid) returns(uint256 );
  function totalBalance() returns(uint256 );
  function getConfig() returns(address );
  function getUsersContract() returns(address );
  function sendCoin(bytes32 _sender,bytes32 _recipient,uint256 _amt);
}


contract Digixbot {
  address owner;
  address config;

  function Digixbot(address _config) {
    owner = msg.sender;
    config = _config;
  }

  modifier ifowner { if(msg.sender == owner) _ }

  function getConfig() public returns (address) {
    return config;
  }

  function getCoinWallet(bytes4 _coin) public returns(address) {
    return DigixbotConfiguration(config).getCoinWallet(_coin);
  }

  function sendCoin(bytes4 _coin, bytes4 _from, bytes4 _to, uint _amount) ifowner {
    address coinwallet = getCoinWallet(_coin);
    Coin(coinwallet).sendCoin(_from, _to, _amount); 
  }
    
  function withdrawCoin(bytes4 _coin, bytes32 _userid, uint _amount) ifowner {
    address coinwallet = getCoinWallet(_coin);
    Coin(coinwallet).withdrawCoin(_userid, _amount);
  }

  function getCoinBalance(bytes4 _coin, bytes32 _userid) public returns(uint) {
    address coinwallet = getCoinWallet(_coin);
    return Coin(coinwallet).getBalance(_userid);
  }

  function getTotalBalance(bytes4 _coin) public returns(uint) {
    address coinwallet = getCoinWallet(_coin);
    return Coin(coinwallet).totalBalance();
  }

}
