// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {FeeToken} from "../src/FeeToken.sol";
import {FeeTokenVault} from "../src/FeeTokenVault.sol";

contract FeeTokenVaultTest is Test {
    FeeToken token;
    FeeTokenVault vault;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        token = new FeeToken();
        vault = new FeeTokenVault(token);
        token.mint(alice, 1000);
    }

    function test_depositKeepsInvariant() public {
        vm.prank(alice);
        vault.deposit(100);
        assertGe(token.balanceOf(address(vault)), vault.totalAssets());
    }

    function test_twoDepositsKeepInvariant() public {
    token.mint(bob, 1000);
    vm.prank(alice);
    vault.deposit(100);
    vm.prank(bob);
    vault.deposit(100);
    assertGe(token.balanceOf(address(vault)), vault.totalAssets());
    }

    function testFuzz_depositKeepsInvariant(uint256 amount) public {
    amount = bound(amount, 1, 1000);
    vm.prank(alice);
    vault.deposit(amount);
    assertGe(token.balanceOf(address(vault)), vault.totalAssets());
    }

    function test_depositThenWithdrawKeepsInvariant() public {
    vm.prank(alice);
    vault.deposit(100);
    vm.prank(alice);
    vault.withdraw(97);
    assertGe(token.balanceOf(address(vault)), vault.totalAssets());
    assertEq(token.balanceOf(alice), 995);
    }

    function test_directTransferCreatesGap() public {
    vm.prank(alice);
    vault.deposit(100);
    vm.prank(alice);
    token.transfer(address(vault), 10);
    assertEq(vault.totalShares(), 97);
    assertEq(token.balanceOf(address(vault)), 107);
    assertGe(token.balanceOf(address(vault)), vault.totalAssets());
    }

    function test_withdrawIgnoresDonation() public {
    vm.prank(alice);
    vault.deposit(100);
    token.mint(address(vault), 97);
    vm.prank(alice);
    vault.withdraw(97);
    assertEq(vault.totalShares(), 0);
    assertEq(token.balanceOf(alice), 995);
    }

    function test_donationDoesNotHurtBob() public {
    token.mint(bob, 1000);
    vm.prank(alice);
    vault.deposit(1);
    token.mint(address(vault), 100);
    vm.prank(bob);
    vault.deposit(150);
    assertEq(vault.shares(bob), 146);
    assertEq(vault.shares(bob) * vault.totalAssets() / vault.totalShares(), 146);
    }

    function test_zeroDepositReverts() public {
    vm.expectRevert("zero shares");
    vm.prank(alice);
    vault.deposit(0);
    }

}    