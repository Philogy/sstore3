// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SSTORE3_L} from "src/SSTORE3_L.sol";

/// @author philogy <https://github.com/philogy>
contract MockSSTORE3_L {
    function write(uint256 pointer, bytes memory data) external returns (address store) {
        return SSTORE3_L.store(pointer, data);
    }

    function read(uint256 pointer) external view returns (bytes memory) {
        return SSTORE3_L.load(pointer);
    }
}
