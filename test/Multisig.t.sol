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
    }

    function testConstructorInitializesCorrectly() public {
        assertEq(multisig.owners(0), owners[0]);
        assertEq(multisig.owners(1), owners[1]);
        assertEq(multisig.required(), required);
    }

    function testCanRecieveEther() public {
        (bool success, ) = address(multisig).call{value: 1 ether}("");
        assertEq(success, true);
        // vm.expectEmit(true, true);
        // emit Deposit(address(this), 1 ether);
        // (bool success2, ) = address(multisig).call{value: 1 ether}("");
    }

    function testOnlyOwnerCanSubmit() public {
        vm.prank(address(user1));
        vm.expectRevert("Not Owner");
        multisig.submit(address(user2), 1 ether, "");
    }

    function testCanSubmitTransaction() public {
        vm.prank(owner1);
        multisig.submit(address(owner2), 1 ether, "");
        // submitTransaction = Multisig.Transaction({
        //     to: owner2,
        //     value: 1 ether,
        //     data: "",
        //     executed: false
        // });
        // assertEq(multisig.transactions(0), submitTransaction);
        // vm.expectEmit(false);
        // emit Submit(0);
    }

    function testCanApproveTransaction() public {
        multisig.submit(address(owner1), 1 ether, "");
        multisig.approve(0);
        assertEq(multisig.getApprovalStatus(0, address(this)), true);
    }

    function testCorrectlyRecordsApprovalCount() public {
        multisig.submit(address(owner1), 1 ether, "");
        multisig.approve(0);
        assertEq(multisig.getApprovalCount(0), 1);
    }
}
