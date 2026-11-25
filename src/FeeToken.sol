// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract FeeToken{
    mapping (address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

     function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 fee = amount * 3 / 100;
        balanceOf[from] -= amount;
        balanceOf[to] += amount - fee;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        uint256 fee = amount * 3 / 100;
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount - fee;
        return true;
    }

}