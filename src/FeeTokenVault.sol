// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
 
 import {FeeToken} from "./FeeToken.sol";

 contract FeeTokenVault {
    FeeToken public token;
    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalAssets;

    constructor(FeeToken _token) {
        token = _token;
    }
    
    function deposit(uint256 amount) external {
    uint256 balanceBefore = token.balanceOf(address(this));
    token.transferFrom(msg.sender, address(this), amount);
    uint256 arrived = token.balanceOf(address(this)) - balanceBefore;

    uint256 newShares;
    if (totalShares == 0) {
        newShares = arrived;
    } else {
        newShares = arrived * totalShares / totalAssets;
    }
    require(newShares > 0, "zero shares");
    shares[msg.sender] += newShares;
    totalShares += newShares;
    totalAssets += arrived;
    }

    function withdraw(uint256 shareAmount) external {
    require(shares[msg.sender] >= shareAmount, "not enough shares");
    uint256 payout = shareAmount * totalAssets / totalShares;
    shares[msg.sender] -= shareAmount;
    totalShares -= shareAmount;
    totalAssets -= payout;
    token.transfer(msg.sender, payout);
    }

 }