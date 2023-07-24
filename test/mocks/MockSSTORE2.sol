// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SSTORE2} from "solady/utils/SSTORE2.sol";

/// @author philogy <https://github.com/philogy>
contract MockSSTORE2 {
    function store(uint256, bytes memory data) external returns (address) {
        return SSTORE2.write(data);
    }
}
