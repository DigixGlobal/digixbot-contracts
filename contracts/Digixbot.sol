contract Digixbot {
  address owner;
  address config;

  function Digixbot(address _config) {
    owner = msg.sender;
    config = _config;
  }
}
