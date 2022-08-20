// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Multisig.sol";

contract MultisigTest is Test {
    Multisig public multisig;

    function setUp() public {
        multisig = new Multisig();
    }

    function testConstructor
}
