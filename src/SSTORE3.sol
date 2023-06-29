// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TransientBuffer} from "./TransientBuffer.sol";

/// @author philogy <https://github.com/philogy>
abstract contract SSTORE3 {
    TransientBuffer private buffer;

    /**
     * ------------------------------------------------------------------------------+
     *                                                                               |
     * CREATION (23 bytes)                                                           |
     *                                                                               |
     * ------------+---------------------------+--------------+----------------------+
     * Opcode      | Mnemonic                  | Stack        | Memory               |
     * ------------+---------------------------+--------------+----------------------+
     *                                                                               |
     * :::: Put `__getStore()` selector in memory. ::::::::::::::::::::::::::::::::: |
     * 63 a817a495 | PUSH4 sel("__getStore()") | s            | -                    |
     * 34          | CALLVALUE                 | 0 s          | [28..32): s          |
     * 52          | MSTORE                    |              | [28..32): s          |
     *                                                                               |
     * :::: Retrieve store data by calling `__getStore()`. ::::::::::::::::::::::::: |
     * 34          | CALLVALUE                 | 0            | [28..32): s          |
     * 34          | CALLVALUE                 | 0 0          | [28..32): s          |
     * 60 04       | PUSH1 0x04                | 4 0 0        | [28..32): s          |
     * 60 1c       | PUSH1 0x1c                | 28 4 0 0     | [28..32): s          |
     * 33          | CALLER                    | c 28 4 0 0   | [28..32): s          |
     * 5a          | GAS                       | g c 28 4 0 0 | [28..32): s          |
     * f3          | STATICCALL                | _            | [28..32): s          |
     *                                                                               |
     * :::: Copy data into memory. ::::::::::::::::::::::::::::::::::::::::::::::::: |
     * 3d          | RETURNDATASIZE            | r _          | [28..32): s          |
     * 34          | CALLVALUE                 | 0 r _        | [28..32): s          |
     * 34          | CALLVALUE                 | 0 0 r _      | [28..32): s          |
     * 3e          | RETURNDATACOPY            | 1            | [0..rds): store data |
     *                                                                               |
     * :::: Return data. ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
     * 3d          | RETURNDATASIZE            | r _          | [0..rds): store data |
     * 34          | CALLVALUE                 | 0 r _        | [0..rds): store data |
     * f3          | RETURN                    | _            | [0..rds): store data |
     * ------------+---------------------------+--------------+----------------------+
     */
    uint256 internal constant STORE_BYTECODE = 0x6362436ce9345234346004601c335afa3d34343e3d34f3;
    uint256 internal constant STORE_INITHASH = 0xd7faf9989a158ef360480b939b5edcc1303fa36a994ba2259497d87719fe94b5;

    error FailedToInitializeStore();
    error DataRangeInvalid(uint256 start, uint256 end);

    function __getStore() external view {
        buffer.directReturn();
    }

    function _bufferInitPrimary() internal {
        buffer.initPrimary();
    }

    function _bufferInitRange(uint256 start, uint256 end) internal {
        buffer.initRange(start, end);
    }

    function sstore3(uint256 pointer, bytes memory data) internal returns (address store) {
        buffer.write(data);
        assembly {
            mstore(0x00, STORE_BYTECODE)
            store := create2(0, 9, 23, pointer)
            if iszero(store) {
                mstore(0x00, 0x8767addc)
                revert(0x1c, 0x04)
            }
        }
        buffer.reset(data.length);
    }

    function sload3(uint256 pointer) internal view returns (bytes memory data) {
        assembly {
            // Allocate memory.
            data := mload(0x40)

            // Compute store location.
            mstore(0x00, address())
            mstore8(0xb, 0xff)
            mstore(0x20, pointer)
            mstore(0x40, STORE_INITHASH)
            let store := keccak256(0xb, 0x55)

            // Get size.
            let size := extcodesize(store)

            // Restore free pointer.
            let dataOffset := add(data, 0x20)
            mstore(0x40, add(dataOffset, size))
            mstore(data, size)

            // Retrieve data.
            extcodecopy(store, dataOffset, 0, size)
        }
    }

    function sload3(uint256 pointer, uint256 start, uint256 end) internal view returns (bytes memory data) {
        assembly {
            // Validate range.
            if gt(start, end) {
                // Revert `DataRangeInvalid`.
                mstore(0x00, 0x1998fa2b)
                mstore(0x20, start)
                mstore(0x40, end)
            }

            // Allocate memory.
            data := mload(0x40)

            // Compute store location.
            mstore(0x00, address())
            mstore8(0xb, 0xff)
            mstore(0x20, pointer)
            mstore(0x40, STORE_INITHASH)
            let store := keccak256(0xb, 0x55)

            // Get size.
            let size := sub(end, start)

            // Restore free pointer.
            let dataOffset := add(data, 0x20)
            mstore(0x40, add(dataOffset, size))
            mstore(data, size)

            // Retrieve data.
            extcodecopy(store, dataOffset, start, size)
        }
    }
}
