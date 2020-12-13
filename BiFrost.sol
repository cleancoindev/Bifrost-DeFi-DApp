pragma solidity ^0.6.0;
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";
import {WTezos} from 'WTezos.sol';

contract MintWrappedToken is ChainlinkClient {
   
    mapping(string => uint ) private whiteListedTezosAddresses;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public value;
    WTezos token;
    mapping (bytes32 => address) private requests;
    event TokenBurned(string indexed, address indexed, uint);


    /**
     * Network: Kovan
     * Oracle: Chainlink - 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
     * Job ID: Chainlink - 29fa9aa13bf1468788b7cc4a500a45b8
     * Fee: 0.1 LINK
     */
    constructor(address tokenAddress) public {
        setPublicChainlinkToken();
        oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        token=WTezos(tokenAddress);
    }
   
      /**
     * To check if  user has deposited Tezos Cryptocurrency and mint wrapped tezos token (ERC20) then in callback function
     * Made request using Chainlink to call the tezos API to get user details and get the amount submitted
     *
     * @return bytes32 request-id for the Chainlink request
     */
    function requestIfAddressWhitelisted()public returns (bytes32)
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
       
        // Set the URL to perform the GET request on
        request.add("get", string(abi.encodePacked("https://api.carthagenet.tzstats.com/explorer/bigmap/19632/", toAsciiString(msg.sender) )));
       
        // request.add("extPath", toAsciiString(msg.sender));

        // // Set the path to find the desired data in the API response, where the response format is:
        request.add("path", "value");

        // Sends the request
        bytes32 temp =  sendChainlinkRequestTo(oracle, request, fee);
       
        //store the request-id
        requests[temp] = msg.sender;
        return temp;
    }
   
    /**
     * Receive the response in the form of uint256 and mint tokens for the user
     *
     * @param _requestId request-of of the Chainlink request
     * @param _value amount of Tezos Cryptocurrency deposited by user
     */
    function fulfill(bytes32 _requestId, uint256  _value) public recordChainlinkFulfillment(_requestId)
    {
        value = _value;
        // mint tokens for the user
        require(value > 0, "0 Tokens can not be minted");
        address temp = requests[_requestId];
        token._mint(temp, value * (10**18));
    }
   
   
     
    /**
     * Burn the tokens for the user and whitelist him to get tezos back
     *
     * @param tezosAddress user address where the tezos will be collected
     * @param amount amount of tokens user wants to Burn
     */
    function requestBurnToken(string memory tezosAddress, uint amount) public {
        require(token.balanceOf(msg.sender) >= amount, "You do not have enough tokens");
        token._burn(msg.sender, amount*(10**18));
        whiteListedTezosAddresses[tezosAddress] = amount*(10**19)/15;
        emit TokenBurned(tezosAddress, msg.sender, amount*(10**19)/15);
    }
   
    // Helper functino - convert address to string
    function toAsciiString(address x) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(abi.encodePacked("0x", string(s))) ;
    }

    function char(byte b) private pure returns (byte c) {
        if (uint8(b) < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
 
}
