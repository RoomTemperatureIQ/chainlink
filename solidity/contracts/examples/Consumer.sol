pragma solidity ^0.4.24;

import "../Chainlinked.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Consumer is Chainlinked, Ownable {
  bytes32 internal specId;
  bytes32 public currentPrice;

  event RequestFulfilled(
    bytes32 indexed requestId,
    bytes32 indexed price
  );

  constructor(address _link, address _oracle, bytes32 _specId) Ownable() public {
    setLinkToken(_link);
    setOracle(_oracle);
    specId = _specId;
  }

  function requestEthereumPrice(string _currency) public {
    ChainlinkLib.Run memory run = newRun(specId, this, "fulfill(bytes32,bytes32)");
    run.add("url", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD,EUR,JPY");
    string[] memory path = new string[](1);
    path[0] = _currency;
    run.addStringArray("path", path);
    chainlinkRequest(run, LINK(1));
  }

  function cancelRequest(bytes32 _requestId) public onlyOwner {
    cancelChainlinkRequest(_requestId);
  }

  function fulfill(bytes32 _requestId, bytes32 _price)
    public
    checkChainlinkFulfillment(_requestId)
  {
    emit RequestFulfilled(_requestId, _price);
    currentPrice = _price;
  }

}
