// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Multisig.sol";

contract MultisigTest is Test {
    Multisig public multisig;
    Multisig.Transaction public submitTransaction;
    address public owner1;
    address public owner2;
    address public user1;
    address public user2;
    address[] public owners;
    uint8 public required;

    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    function setUp() public {
        owner1 = address(0x1);
        owner2 = address(0x2);
        user1 = address(0x3);
        user2 = address(0x4);
        owners.push(owner1);
        owners.push(owner2);
        owners.push(address(this));
        required = 2;
        multisig = new Multisig(owners, required);
        (bool success, ) = address(multisig).call{value: 10 ether}("");
        require(success, "Couldn't send money to Multisig contract");
    }

    function testConstructorInitializesCorrectly() public {
        assertEq(multisig.owners(0), owners[0]);
        assertEq(multisig.owners(1), owners[1]);
        assertEq(multisig.required(), required);
    }

    function testCanRecieveEther() public {
        vm.expectEmit(true, true, false, false);
        emit Deposit(address(this), 1 ether);
        (bool success, ) = address(multisig).call{value: 1 ether}("");
        assertEq(success, true);
    }

    function testOnlyOwnerCanSubmit() public {
        vm.prank(address(user1));
        vm.expectRevert("Not Owner");
        multisig.submit(address(user2), 1 ether, "");
    }

    function testOwnerCanSubmitTransaction() public {
        vm.prank(owner1);
        vm.expectEmit(true, false, false, false);
        emit Submit(0);
        multisig.submit(address(owner2), 1 ether, "");
    }

    function testCanApproveTransaction() public {
        vm.startPrank(owner1);
        multisig.submit(user1, 1 ether, "");

        vm.expectEmit(true, true, false, false);
        emit Approve(owner1, 0);
        multisig.approve(0);

        vm.stopPrank();
    }

    function testCorrectlyRecordsApprovalCount() public {
        multisig.submit(address(owner1), 1 ether, "");
        multisig.approve(0);
        assertEq(multisig.getApprovalCount(0), 1);
    }

    function testProperlyExecutesTransaction() public {
        vm.prank(owner1);
        multisig.submit(user1, 1 ether, "");

        vm.prank(owner1);
        multisig.approve(0);

        vm.prank(owner2);
        multisig.approve(0);

        vm.expectEmit(true, false, false, false);
        emit Execute(0);
        multisig.execute(0);
    }

    function testCanRevoke() public {
        vm.prank(owner1);
        multisig.submit(user1, 1 ether, "");

        vm.prank(owner1);
        multisig.approve(0);

        vm.prank(owner2);
        multisig.approve(0);

        vm.prank(owner1);
        multisig.revoke(0);

        vm.expectRevert("Approvals < required");
        multisig.execute(0);
    }
}
