// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {TransientBuffer} from "src/TransientBuffer.sol";

/// @author philogy <https://github.com/philogy>
contract MockBuffer {
    TransientBuffer private buffer;

    function write(bytes memory data) external {
        buffer.write(data);
    }

    function reset(uint256 size) external {
        buffer.reset(size);
    }

    function read() external view {
        buffer.directReturn();
    }
}
