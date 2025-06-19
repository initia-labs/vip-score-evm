// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "src/VipScore.sol";

contract VipScoreTest is Test {
    VipScore vip;
    address owner;
    address other;

    function setUp() public {
        owner = address(this);
        other = address(0xBEEF);
        vip = new VipScore(1); // initStage = 1
    }

    function testOwnerInAllowList() public {
        assertTrue(vip.allowList(owner));
    }

    function testInnerEndToEnd() public {
        (uint64 id, uint64 total, bool fin) = vip.stages(1);
        assertEq(id, 1);
        assertEq(total, 0);
        assertFalse(fin);

        vip.increaseScore(1, other, 100);
        (, total,) = vip.stages(1);
        assertEq(total, 100);
        (, uint64 amt) = vip.scores(1, other);
        assertEq(amt, 100);

        vip.decreaseScore(1, other, 50);
        (, total,) = vip.stages(1);
        assertEq(total, 50);
        (, amt) = vip.scores(1, other);
        assertEq(amt, 50);

        vip.updateScore(1, other, 200);
        (, total,) = vip.stages(1);
        assertEq(total, 200);
        (, amt) = vip.scores(1, other);
        assertEq(amt, 200);

        address[] memory addrs = new address[](2);
        uint64[] memory amounts = new uint64[](2);
        addrs[0] = other;
        addrs[1] = owner;
        amounts[0] = 100;
        amounts[1] = 500;

        // // length mismatch
        address[] memory badAddrs = new address[](1);
        badAddrs[0] = other;
        vm.expectRevert(AddrsAndAmountsLengthMistmatch.selector);
        vip.updateScores(1, badAddrs, amounts);

        vip.updateScores(1, addrs, amounts);
        (, total,) = vip.stages(1);
        assertEq(total, 600);
        (, amt) = vip.scores(1, other);
        assertEq(amt, 100);
        (, amt) = vip.scores(1, owner);
        assertEq(amt, 500);

        vip.finalizeStage(1);
        (,, fin) = vip.stages(1);
        assertTrue(fin);

        /* getScores view */
        VipScore.ScoreResponse[] memory res = vip.getScores(1, 0, 5);
        assertEq(res[0].addr, other);
        assertEq(res[0].amount, 100);
        assertEq(res[0].index, 1);
        assertEq(res[1].addr, owner);
        assertEq(res[1].amount, 500);
        assertEq(res[1].index, 2);

        /* ops on finalized stage should revert */
        vm.expectRevert(abi.encodeWithSelector(StageFinalized.selector, uint64(1)));
        vip.increaseScore(1, other, 100);
        vm.expectRevert(abi.encodeWithSelector(StageFinalized.selector, uint64(1)));
        vip.decreaseScore(1, other, 100);
        vm.expectRevert(abi.encodeWithSelector(StageFinalized.selector, uint64(1)));
        vip.updateScore(1, other, 100);

        /* allow list add / remove */
        vip.addAllowList(other);
        assertTrue(vip.allowList(other));
        vip.removeAllowList(other);
        assertFalse(vip.allowList(other));
    }
}
