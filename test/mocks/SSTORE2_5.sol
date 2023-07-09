// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CREATE3} from "solady/utils/CREATE3.sol";

/// @author philogy <https://github.com/philogy>
library SSTORE2_5 {
    error DataTooLarge();

    uint256 internal constant DEPLOY_CODE_HEAD = 0x61000080600a3d393df300;
    uint256 internal constant HEAD_LENGTH = 11;

    function write(uint256 pointer, bytes memory data) internal returns (address store) {
        uint256 prevWordPos;
        uint256 prevWord;
        uint256 originalLength;
        bytes memory deployCode;
        assembly {
            prevWordPos := sub(data, 0x20)
            prevWord := mload(prevWordPos)
            originalLength := mload(data)
            if iszero(lt(originalLength, 24576)) {
                mstore(0x00, 0x54ef47ee)
                revert(0x1c, 0x04)
            }
            mstore(data, or(DEPLOY_CODE_HEAD, shl(64, originalLength)))
            deployCode := sub(data, HEAD_LENGTH)
            mstore(deployCode, add(originalLength, HEAD_LENGTH))
        }

        store = CREATE3.deploy(bytes32(pointer), deployCode, 0);

        assembly {
            mstore(prevWordPos, prevWord)
            mstore(data, originalLength)
        }
    }
}
