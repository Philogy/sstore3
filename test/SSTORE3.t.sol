// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {MockSSTORE3} from "./mocks/MockSSTORE3.sol";

/// @author philogy <https://github.com/philogy>
contract SSTORE3Test is Test {
    MockSSTORE3 s;

    uint256 internal constant DATA_CAP = 24575;

    function setUp() public {
        s = new MockSSTORE3(64);
    }

    function test_fuzzingStoreLoad(uint256 pointer, bytes memory data) public {
        uint256 boundLength = bound(data.length, 0, DATA_CAP);
        assembly {
            mstore(data, boundLength)
        }
        address storeAddr = s.store(pointer, data);

        bytes memory dataOut = s.load(pointer);
        assertEq(dataOut, data);
        assertEq(storeAddr.code, abi.encodePacked(bytes1(hex"00"), data));
    }

    function test_test() public {
        test_fuzzingStoreLoad(0, hex"");
    }
}
