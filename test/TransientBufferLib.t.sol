// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {MockBuffer} from "./mocks/MockBuffer.sol";

/// @author philogy <https://github.com/philogy>
contract TransientBufferTest is Test {
    MockBuffer buffer;

    function setUp() public {
        buffer = new MockBuffer();
    }

    function testDefault() public {
        assertEq(readBuffer(), new bytes(0));
    }

    function testWriteRead(bytes memory randomBytes) public {
        uint256 boundLength = bound(randomBytes.length, 0, 24576);
        assembly {
            mstore(randomBytes, boundLength)
        }
        buffer.write(randomBytes);
        assertEq(readBuffer(), randomBytes);
    }

    function readBuffer() internal returns (bytes memory) {
        (bool success, bytes memory contents) = address(buffer).staticcall(abi.encodeCall(MockBuffer.read, ()));
        assertTrue(success);
        return contents;
    }
}
