// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract ForcedEtherGameFixed {

uint256 public deposited;
address public winner;

function deposit() external payable {
    require(msg.value == 1 ether);
    require(deposited < 7 ether);
    deposited += msg.value;
    if (deposited == 7 ether) {
        winner = msg.sender;
    }
}

function claim() external {
     require(msg.sender == winner);
     uint256 prize = 7 ether;
     (bool ok,) = msg.sender.call{value: prize}("");
     require(ok);
    winner = address(0);
 }

}