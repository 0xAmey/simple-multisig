// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SimpleMultisig.sol";

contract CounterTest is Test {
    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }
}
