// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SSTORE3_S} from "src/SSTORE3_S.sol";

/// @author philogy <https://github.com/philogy>
contract MockSSTORE3_S is SSTORE3_S {
    constructor(uint256 initEnd) {
        _bufferInitPrimary();
        _bufferInitRange(0, initEnd);
    }

    function store(uint256 pointer, bytes memory data) external returns (address) {
        return sstore3(pointer, data);
    }

    function load(uint256 pointer) external view returns (bytes memory) {
        return sload3(pointer);
    }

    function load(uint256 pointer, uint256 start, uint256 end) external view returns (bytes memory) {
        return sload3(pointer, start, end);
    }
}
