// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


import "forge-std/Test.sol";
import "../src/ForcedEtherGameFixed.sol";
import "../src/ForcedEtherBomb.sol";
import "../src/ForcedEtherGame.sol";

contract ForcedEtherGameTest is Test {
    ForcedEtherGame game;
    ForcedEtherBomb bomb;
    ForcedEtherGameFixed fixedGame;

    function setUp() public {
      game = new ForcedEtherGame();
      bomb = new ForcedEtherBomb();
      fixedGame = new ForcedEtherGameFixed();
    }

      function test_BombFreezesVulnerableGame() public {
        // six players, 1 ether each
        for (uint256 i = 1; i <= 6; i++) {
          address player = address(uint160(0x1000 + i));
          vm.deal(player, 1 ether);
          vm.prank(player);
          game.deposit{value: 1 ether}();
        }
        // the Bomb gets 1 wei and fires at the game
        vm.deal(address(bomb), 1 wei);
         bomb.blast(address(game));

         assertEq(address(game).balance, 6 ether + 1 wei);

         // the 7th deposit must fail
         
        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);
        vm.expectRevert();
        vm.prank(bob);
        game.deposit{value: 1 ether}();

    }
     function test_BombDoesNotFreezeFixedGame() public {
      for (uint256 i = 1; i <= 6; i++) {
          address player = address(uint160(0x1000 + i));
          vm.deal(player, 1 ether);
          vm.prank(player);
          fixedGame.deposit{value: 1 ether}();
        }

        vm.deal(address(bomb), 1 wei);
        bomb.blast(address(fixedGame));
        assertEq(address(fixedGame).balance, 6 ether + 1 wei);

        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);
        vm.prank(bob);
        fixedGame.deposit{value: 1 ether}();

        assertEq(fixedGame.winner(), bob);
     }
}
